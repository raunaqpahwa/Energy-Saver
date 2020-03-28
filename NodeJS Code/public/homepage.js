var socket = io();
var modal = document.getElementById('modal');
const modalbtn = document.getElementById('modal-btn');
const onButton = document.getElementById('on');
const offButton = document.getElementById('off');
const generatePieButton = document.getElementById('generatePie');
const generateLineButton = document.getElementById('generateLine');
const thresholdBox = document.getElementById('threshold');
const submitThreshold = document.getElementById('submitThreshold');
var state,threshold,power;
generatePieButton.addEventListener('click',function(){
    socket.emit('generatePieChart');
});
generateLineButton.addEventListener('click',function()
{
    socket.emit('generateLineChart');
});
document.addEventListener('DOMContentLoaded',function(){
    const domLoad = true;
    socket.emit('domLoaded',domLoad);
});
socket.on('newMessage',function(msg)
{
    var topic = msg.topic;
    var data = msg.message;
    if(topic == "Harman_singh/feeds/onoff")
    {
        state = data;
        document.querySelector('#state').innerHTML = `The appliance is currently ${data}`;
        if((threshold-power) < 0 && data == "off")
        {
            modal.style.display = "block";
        }
    }
    else if(topic == "Harman_singh/feeds/threshold")
    {
        threshold = data;
        document.querySelector('#thresholdValue').innerHTML = `The current value for threshold is ${Math.abs(data)}`;
        if( power != null )
        {
            if( data-power > 0 )
                document.querySelector('#remainingu').innerHTML = `Remaining units are ${Math.abs((data-abs(power)).toPrecision(2))}`;
            else
            {
                document.querySelector('#remainingu').innerHTML = 'Remaining units are 0';
            }
                
        }
        else{
            document.querySelector('#remainingu').innerHTML = 'Remaining units are 0';
        }
        socket.emit('generatePieChart');
        socket.emit('generateLineChart');
    }
    else if(topic == "Harman_singh/feeds/power")
    {
        power = data;
        document.querySelector('#powerValue').innerHTML = `The current power consumption is ${Math.abs(data)}`;
        if( threshold != null )
        {
            if( threshold-data > 0 )
                document.querySelector('#remainingu').innerHTML = `Remaining units are ${Math.abs((threshold-abs(data)).toPrecision(2))}`;
            else
            {
                document.querySelector('#remainingu').innerHTML = 'Remaining units are 0';
            }
            
        }
        else{
            document.querySelector('#remainingu').innerHTML = 'Remaining units are 0';
        }
        socket.emit('generatePieChart');
        socket.emit('generateLineChart');
    }
});
socket.on('connectedInitial',function(msg){
    console.log(msg.state);
    state = msg.state;
    threshold = msg.threshold;
    power = msg.power;
    if( state == null )
        document.querySelector('#state').innerHTML = "Cannot determine if the appliance is on/off";
    else
        document.querySelector('#state').innerHTML = `The appliance is currently ${state}`;
    if( threshold == null )
        document.querySelector('#thresholdValue').innerHTML = "Cannot determine the current value for threshold"
    else
        document.querySelector('#thresholdValue').innerHTML = `The current value for threshold is ${threshold}`;
    if( power == null )
        document.querySelector('#powerValue').innerHTML = "Cannot determine the current power consumption";
    else
        document.querySelector('#powerValue').innerHTML = `The current power consumption is ${power}`;
    if( power != null && threshold != null )
    {
        if( threshold-power >= 0 )
            document.querySelector('#remainingu').innerHTML = `Remaining units are ${threshold-power}`;
        else
            document.querySelector('#remainingu').innerHTML = 'Remaining units are 0';
        socket.emit('generatePieChart');
        socket.emit('generateLineChart');
    }
    else{
        document.querySelector('#remainingu').innerHTML = "Cannot determine remaining units";
    }
});
socket.on('pieChartClient',function(msg){
    var threshold = msg.threshold;
    var power = msg.power;
    var ctx = document.getElementById('pieCompare');
    var config = {type : 'pie',
    data : {
        datasets: [{
            data: [threshold,power],
    backgroundColor:[
        '#C7CEEA',
        '#CE9DD9'
    ],
    label : 'Power vs Threshold'}],
        labels: [
            'Threshold',
            'Power',
        ]},options : {responsive:true,animation:{duration:500},title:{display:true,
        position:"top",text:"Power vs Threshold",fontSize:14,fontColor: "#111"},legend:{
            display:true,position:"bottom",labels: {
                fontColor: "#333",
                fontSize: 14
              }
        }}
        }
    var pieChart = new Chart(ctx,config);
});
socket.on('lineChartClient',function(msg){
    var ctx = document.getElementById('lineCompare');
    console.log(msg.power);
    var data = {
        labels : msg.time,
        datasets : [
            {
                label: 'Power consumption',
                data : msg.power,
                backgroundColor: '#FFB9B3',
                borderColor: "#FFD5B8",
                fill: false,
                lineTension: 0,
                radius: 5
            }
        ]
    };
    var options = {
        responsive: true,
        elements: {
            line: {
                tension: 0
            }
        },
        gridLines: {display: false},
        title: {
          display: true,
          position: "top",
          text: "Power Consumption with Time",
          fontSize: 14,
          fontColor: "#111"
        },
        legend: {
          display: true,
          position: "bottom",
          labels: {
            fontColor: "#333",
            fontSize: 14
          }
        }
      }; 
    var config = {type : 'line',
        data: data,
    options : options};
    var lineChart = new Chart(ctx,config);
});
submitThreshold.addEventListener('click',()=>{
    const threshold = thresholdBox.value;
    console.log(threshold);
    if(threshold > 0)
        socket.emit('thresholdChanged',threshold)
    thresholdBox.value = "";
});
onButton.addEventListener('click', () => {
    fetch('/switchOn',{method:'GET'});
});
offButton.addEventListener('click', () => {
    fetch('/switchOff',{method:'GET'});
});
modalbtn.addEventListener('click',()=>{
    modal.style.display = "none";
})
function noenter() {
    return !(window.event && window.event.keyCode == 13); }