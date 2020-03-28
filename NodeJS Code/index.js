var mqtt = require('mqtt');
var express = require('express');
var app = express();
var http = require('http');
var moment = require('moment');
var fs = require('fs');
const {Parser} = require('json2csv');
var bodyParser = require('body-parser');
var server = http.createServer(app);
var io = require('socket.io')(server);
var urlencodedParser = bodyParser.urlencoded({ extended: false });
var client,state,threshold,power;
function appendToCSVPower(message)
{
    var newLine = '\n';
    var date = new Date().toISOString();
    var fields = ['Date','Power'];
    var toAppend = [
        {
            'Date': date,
            'Power': message
        }
    ];
    const json2csvParser = new Parser({fields,header:false});
    const csv = json2csvParser.parse(toAppend) + newLine;
    fs.stat('power.csv',function(err,stat)
    {
        if( err == null )
        {
            console.log('File exists');
            fs.appendFile('power.csv',csv,function(err){
                if(err)
                    console.log(err)
                console.log('The data was appended to file');
            });
        }
        else
        {
            console.log('New file writing headers');
            fields = (fields + newLine);
            fs.writeFileSync('power.csv',fields,function(err)
            {
                if(err)
                    console.log(err)
                console.log('File written');
            });
            fs.appendFile('power.csv',csv,function(err){
                if(err)
                    console.log(err)
                console.log('The data was appended to file');
            });
        }
    });
}
function appendToCSVState(message)
{
    var newLine = '\n';
    var date = new Date().toISOString();
    var fields = ['Date','State'];
    var toAppend = [
        {
            'Date': date,
            'State': message
        }
    ];
    const json2csvParser = new Parser({fields,header:false});
    const csv = json2csvParser.parse(toAppend) + newLine;
    fs.stat('state.csv',function(err,stat)
    {
        if( err == null )
        {
            console.log('File exists');
            fs.appendFile('state.csv',csv,function(err){
                if(err)
                    console.log(err)
                console.log('The data was appended to file');
            });
        }
        else
        {
            console.log('New file writing headers');
            fields = (fields + newLine);
            fs.writeFileSync('state.csv',fields,function(err)
            {
                if(err)
                    console.log(err)
                console.log('File written');
            });
            fs.appendFile('state.csv',csv,function(err){
                if(err)
                    console.log(err)
                console.log('The data was appended to file');
            });
        }
    });
}
function appendToCSVThreshold(message)
{
    var newLine = '\n';
    var date = new Date().toISOString();
    var fields = ['Date','Threshold'];
    var toAppend = [
        {
            'Date': date,
            'Threshold': message
        }
    ];
    const json2csvParser = new Parser({fields,header:false});
    const csv = json2csvParser.parse(toAppend) + newLine;
    fs.stat('threshold.csv',function(err,stat)
    {
        if( err == null )
        {
            console.log('File exists');
            fs.appendFile('threshold.csv',csv,function(err){
                if(err)
                    console.log(err)
                console.log('The data was appended to file');
            });
        }
        else
        {
            console.log('New file writing headers');
            fields = (fields + newLine);
            fs.writeFileSync('threshold.csv',fields,function(err)
            {
                if(err)
                    console.log(err)
                console.log('File written');
            });
            fs.appendFile('threshold.csv',csv,function(err){
                if(err)
                    console.log(err)
                console.log('The data was appended to file');
            });
        }
    });
}
function getAnalysisValues(filename)
{
    if( fs.existsSync(filename) )
    {
        var content = fs.readFileSync(filename,'utf-8',function(err,data){
            if( err )
                throw err;
        });
        var lines = content.trim().split('\n');
        var linesSub = lines.slice(1,lines.length);
        if( linesSub.length == 0 )
            return null;
        var time = [];
        var val = [];
        for(var i = 0 ; i < linesSub.length ; i++)
        {
            var fields = linesSub[i].split(',');
            var cDate = fields[0].substring(1,fields[0].length-1);
            time.push(moment(cDate).format("DD-MM-YYYY h:mm"));
            val.push(parseFloat(fields[1].substring(1,fields[1].length-1),10));
        }
        var lineChartValues = {time: time,power : val};
        return lineChartValues;
    }
    else
    {
        return null;
    } 
}
function getCurrentValues(filename)
{
    console.log('Inside values function');
    if( fs.existsSync(filename) )
    {
        var content = fs.readFileSync(filename,'utf-8',function(err,data){
            if( err )
                throw err;
        });
        var lines = content.trim().split('\n');
        var lastLine = lines.slice(-1)[0];
        var fields = lastLine.split(',')[1];
        return fields;
    }
    else
    {
        return null;
    }
}
app.use(express.static(__dirname+'/public'));
app.get('/',function(request,response){
    response.sendFile(__dirname+'/html/'+'login.html');
});
app.post('/page',urlencodedParser,function(request,response)
{
    var username = request.body.username;
    var password = request.body.password;
    client = mqtt.connect('mqtt://io.adafruit.com',{host:'io.adafruit.com',port:1883,username:username,password:password});
    client.subscribe('Harman_singh/feeds/onoff',function(err)
        {
            if(err)
                console.log(err);
        });
    client.subscribe('Harman_singh/feeds/threshold',function(err)
        {
            if(err)
                console.log(err);
        });
    client.subscribe('Harman_singh/feeds/power',function(err){
        if(err)
            console.log(err);
    });
    client.on('connect',function()
    {
        console.log('Connected to the MQTT Client');
        state = getCurrentValues('state.csv');
        threshold = getCurrentValues('threshold.csv');
        power = getCurrentValues('power.csv');
        if( state != null )
            state = state.substring(1,state.length-1);
        if( threshold != null )
            threshold = threshold.substring(1,threshold.length-1);
        if( power != null )
            power = power = power.substring(1,power.length-1);
        response.sendFile(__dirname+'/html/'+'homepage.html');  
    });
    client.on("error",function(error)
    {
        if(error)
        {
            response.sendFile(__dirname+'/html/'+'error.html');
        }     
    });   
    client.on("disconnect",function(error){
        response.sendFile(__dirname+'/html/'+'error.html');
    });
    client.on('message',function(topic,message,packet){
        message = message.toString('utf-8');
        var responseObject = {topic:topic,message:message};
        if(topic == 'Harman_singh/feeds/power')
        {
            power = message;
            appendToCSVPower(message);
        }
        else if(topic == 'Harman_singh/feeds/onoff')
        {
            state = message;
            appendToCSVState(message);
        }  
        else if(topic == 'Harman_singh/feeds/threshold')
        {
            threshold = message;
            appendToCSVThreshold(message);
        }
        io.emit('newMessage', responseObject); 
    });
});     
    
io.on('connection',function(socket)
{
    socket.on('thresholdChanged',function(msg){
        var threshold = msg;
        client.publish('Harman_singh/feeds/threshold',threshold,function(err)
        {
            if(err)
                console.log(err);
        });
    });
    socket.on('generateLineChart',function(){
        var lineChartResponse = getAnalysisValues('power.csv');
        if( lineChartResponse != null )
            io.emit('lineChartClient',lineChartResponse);
    });
    socket.on('generatePieChart',function(){
        var pieChartResponse = {threshold:threshold,power:power};
        io.emit('pieChartClient',pieChartResponse);
    });
    socket.on('domLoaded',function(msg){
        var responseObject = {state:state,threshold:threshold,power:power};
        if( state != null )
            client.publish('Harman_singh/feeds/onoff',state,function(err){
                if( err )
                    console.log(err);
            });
        if ( threshold != null )
            client.publish('Harman_singh/feeds/threshold',threshold,function(err){
                if( err )
                    console.log(err);
            });
        if( power != null )
            client.publish('Harman_singh/feeds/power',power,function(err){
                if( err )
                    console.log(err);
            });
        io.emit('connectedInitial',responseObject);
    });
});   
app.get('/switchOn',function(request, response){
    console.log("Switched On");
    if( client != undefined && client.connected )
        client.publish('Harman_singh/feeds/onoff','on',function(err){
            if(err)
                console.log(err);
    });
  });
app.get('/switchOff',function(request,response){
    console.log("Switched Off");
    if( client != undefined && client.connected )
        client.publish('Harman_singh/feeds/onoff','off',function(err){
            if(err)
                console.log(err);
    });
});
server.listen(3000);