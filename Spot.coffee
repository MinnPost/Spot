# Description:
#   Control Spot from campfire. https://github.com/minton/spot
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_SPOT_URL
#
# Commands:
#   hubot play! - Plays current playlist or song.
#   hubot pause - Pause the music.
#   hubot play next - Plays the next song.
#   hubot play back - Plays the previous song.
#   hubot playing? - Returns the currently-played song.
#   hubot play <song> - Play a particular song. This plays the first most popular result.
#   hubot volume? - Returns the current volume level.
#   hubot volume [0-100] - Sets the volume.
#   hubot mute - Sets the volume to 0.
#
# Author:
#   mcminton

URL = "#{process.env.HUBOT_SPOT_URL}"

spotRequest = (message, path, action, options, callback) ->
  message.http("#{URL}#{path}")
    .query(options)[action]() (err, res, body) ->
      callback(err,res,body)

module.exports = (robot) ->

  robot.respond /play!/i, (message) ->
    message.finish()
    spotRequest message, '/play', 'put', {}, (err, res, body) ->
      message.send(":notes:  #{body}")
  
  robot.respond /pause/i, (message) ->
    params = {volume: 0}
    spotRequest message, '/pause', 'put', params, (err, res, body) ->
      message.send("#{body} :cry:")
  
  robot.respond /next/i, (message) ->
    spotRequest message, '/next', 'put', {}, (err, res, body) ->
      message.send("#{body} :fast_forward:")
  
  robot.respond /back/i, (message) ->
    spotRequest message, '/back', 'put', {}, (err, res, body) ->
      message.send("#{body} :rewind:")

  robot.respond /playing\?/i, (message) ->
    spotRequest message, '/playing', 'get', {}, (err, res, body) ->
      message.send("#{URL}/playing.png")
      message.send(":notes:  #{body}")

  robot.respond /volume\?/i, (message) ->
    spotRequest message, '/volume', 'get', {}, (err, res, body) ->
      message.send("Spot volume is #{body}. :mega:")

  robot.respond /mute/i, (message) ->
    spotRequest message, '/mute', 'put', {}, (err, res, body) ->
      message.send("#{body} :mute:")

  robot.respond /volume (.*)/i, (message) ->
    params = {volume: message.match[1]}
    spotRequest message, '/volume', 'put', params, (err, res, body) ->
      message.send("Spot volume set to #{body}. :mega:")

  robot.respond /play (.*)/i, (message) ->
    params = {q: message.match[1]}
    spotRequest message, '/find', 'post', params, (err, res, body) ->
      message.send(":small_blue_diamond: #{body}")

  robot.respond /(.*) says turn it down.*/i, (message) ->
    name = message.match[1]
    params = {volume: 15}
    spotRequest message, '/volume', 'put', params, (err, res, body) ->
     message.send("#{name} says, 'Turn down the music and get off my lawn!' :bowtie:")