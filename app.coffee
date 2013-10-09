Twit = require 'twit'

tw = new Twit
  consumer_key:        process.env.TW_CONSUMER_KEY
  consumer_secret:     process.env.TW_CONSUMER_SECRET
  access_token:        process.env.TW_ACCESS_TOKEN_KEY
  access_token_secret: process.env.TW_ACCESS_TOKEN_SECRET

incorrect = 'vise versa'
correct = 'vice versa'

advice = ((c) -> [
  "I think you mean '#{c}'"
  "Did you mean '#{c}'?"
  "Actually, it's spelled '#{c}'"
  "The correct spelling is '#{c}'"
])(correct)

filter = incorrect.split(' ').slice(-1)

incorrect_match = new RegExp incorrect.replace(/\ +/g, '\\s+'), 'i'
correct_match = new RegExp correct.replace(/\ +/g, '\\s+'), 'i'

stream = tw.stream 'statuses/filter', track: filter

console.log 'Listening...'

stream.on 'tweet', (tweet) ->
  return unless incorrect_match.test(tweet.text) &&
    !correct_match.test(tweet.text) &&
    !tweet.retweeted_status?

  msg = "@#{tweet.user.screen_name} " +
    advice[Math.floor Math.random()*advice.length]

  console.log "Replying to #{tweet.user.screen_name}"

  tw.post 'statuses/update', {
    status: msg
    in_reply_to_status_id: tweet.id_str
  }, (err, reply) -> console.error err if err
