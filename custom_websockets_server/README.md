# Websockets!!!

This is a custom websockets implementation, the idea is to understand how the websocket protocol works.

It implements:

- Handling the initial http request from each client.
- Doing the websocket handshake when the browser requests a websocket connection.
- It stores each connection in a separate thread.
- Each thread runs a loop that reads each frame that is sent to the server.
- We also have a simple Ping-Pong back and forth, this happens with a button in the UI but could be reimplemented using a setInterval or something similar.
- And lastly, we have a broadcast function that is able to send a message to all connected clients.
- TODO: It currently does not handle closing the websocket connections properly, as there's another handshake involved. I was lazy and stopped at this point :)