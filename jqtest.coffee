# Useful site: http://www.datafiddle.net/allscripts

if Meteor.isClient
  Template.hello.helpers
    hockeyUrl: -> "http://www.hockey-reference.com/players/s/shacked01.html"
    hockeyFormat: -> "#stats_basic_nhl > thead > tr:nth-child(2) > th"
    
  Template.hello.events
    'click #bt_ch': () ->
      Meteor.call "chScrape", tb_url.value, tb_format.value,
        (error, result) ->
          console.log "click ", result
          Session.set "header", result
          tb_ch.value = result
      
    'click #bt_jq': () ->
      Meteor.call "jqScrape", tb_url.value, tb_format.value,
        (error, result) ->
          console.log "click ", result
          Session.set "header", result
          tb_jq.value = result

if Meteor.isServer
  Meteor.methods
    chScrape: (url, format) -> 
      html = Meteor.http.get(url)

      $ = Meteor.npmRequire("cheerio").load(html.content)
      chResults = $(format)
        .map (i, elem) ->
          $(elem).text()
        .get().join(" ")
      console.log "chResults ", chResults
      chResults
  
    jqScrape: (url,format) ->
      html = Meteor.http.get(url)
      
      # http://stackoverflow.com/questions/21358015/error-jquery-requires-a-window-with-a-document
      jq = Meteor.npmRequire("jquery")(Meteor.npmRequire("jsdom").jsdom().parentWindow)
      jqDoc = jq(html.content)

      # http://stackoverflow.com/questions/23866237/jquery-cheerio-going-over-an-array-of-elements
      jqResults = jqDoc
        .find(format)
        .map (i, elem) ->
          jq(elem).text()
        .get().join(" ")
      console.log "jqResults ", jqResults
      jqResults