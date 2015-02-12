#!/usr/bin/env ruby -I ../lib -I lib
# coding: utf-8
require 'sinatra'
set :server, 'thin'
connections = []
get '/' do
halt erb(:login) unless params[:user]
erb :chat, :locals => { :user => params[:user].gsub(/\W/, '') }
end
get '/stream', :provides => 'text/event-stream' do
stream :keep_open do |out|
connections << out
out.callback { connections.delete(out) }
end
end
post '/' do
connections.each { |out| out << "data: #{params[:msg]}\n\n" }
204 # response without entity body
end
__END__
@@ layout
<html>
<head>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap-theme.min.css">
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/js/bootstrap.min.js"></script>
<title>Le Chat de ouf avec Sinatra !</title>
<meta charset="utf-8" />
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>
</head>
<body><%= yield %></body>
</html>
@@ login
<form action='/'>
<label for='user'>Pseudo :</label>
<input name='user' value='' />
<input type='submit' value="Chattons !" />
</form>
@@ chat
<pre id='chat'></pre>
<form>
<input id='msg' placeholder='Tape ton message ici !' />
</form>
<script>
// reading
var es = new EventSource('/stream');
es.onmessage = function(e) { $('#chat').append(e.data + "\n") };
// writing
$("form").on('submit',function(e) {
$.post('/', {msg: "<%= user %>: " + $('#msg').val()});
$('#msg').val(''); $('#msg').focus();
e.preventDefault();
});
</script>