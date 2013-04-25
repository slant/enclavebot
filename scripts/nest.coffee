# Description:
#   Control your nest thermostat.
#
# Commands:
#   hubot how (warm|cold) is it - current temperature
#   hubot it's warm - set the nest 1 degree Fahrenheit lower
#   hubot it's cold - set the nest 1 degree Fahrenheit higher
#   hubot nest status - current nest setting

# https://github.com/kasima/nesting
nest = require('nesting')

# Be sure to set the following environment variables
options =
  login:    process.env.NEST_LOGIN
  password: process.env.NEST_PASSWORD
  nest_id:  process.env.NEST_ID


changeTemperatureBy = (byF, msg) ->
  nest.fetchStatus (data) ->
    byC = (5/9) * byF
    current_temp = data.shared[options.nest_id].target_temperature
    new_temp = current_temp + byC
    msg.send "I've set the nest to " + nest.ctof(new_temp) + 'ºF for you.'
    nest.setTemperature options.nest_id, new_temp

changeTemperatureTo = (toF, msg) ->
  console.log toF
  nest.fetchStatus (data) ->
    toC = nest.ftoc(toF)
    msg.send "I've set the nest to " + nest.ctof(toC) + 'ºF for you.'
    console.log nest.ctof(toC)
    console.log toC
    nest.setTemperature options.nest_id, toC


module.exports = (robot) ->
  robot.respond /how (warm|cold) is it\?/i, (msg) ->
    msg.send("Checking...")
    nest.login options.login, options.password, (data) ->
      nest.fetchStatus (data) ->
        current_temp = data.shared[options.nest_id].current_temperature
        msg.send "The temperature is currently " + nest.ctof(current_temp) + "ºF."

  robot.hear /it'?s(.*)( really)? (hot|warm)|nest (down|cooler|colder)/i, (msg) ->
    msg.send("Decreasing the temperature...")
    nest.login options.login, options.password, (data) ->
      changeTemperatureBy -1, msg

  robot.hear /it'?s(.*) cold|nest (up|warmer)/i, (msg) ->
    msg.send("Increasing the temperature...")
    nest.login options.login, options.password, (data) ->
      changeTemperatureBy +1, msg

  robot.respond /nest set (\d{2}).*/i, (msg) ->
    nest.login options.login, options.password, (data) ->
      changeTemperatureTo msg.match[1], msg

  robot.respond /nest status/i, (msg) ->
    msg.send("Checking...")
    nest.login options.login, options.password, (data) ->
      nest.fetchStatus (data) ->
        current_target = data.shared[options.nest_id].target_temperature
        msg.send "The nest is currently set to " + nest.ctof(current_target) + "ºF."

