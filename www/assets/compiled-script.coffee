###
This file is compiled from CoffeeScript and served as JavaScript.
###

console.log 'CoffeeScript!'

if document.body.dataset.showing_tag is 'true'
    window.scrollTo(0, document.getElementById('instagram_photos').offsetTop) 
