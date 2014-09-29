/*
  D3 County Map Template
  Ben Southgate
  9/29/14
*/

(function(){

"use strict";

// Extend Urban Module
var Urban = Urban || {};
Urban.Map = Urban.Map || {};


function error(text) {
  throw "County Map Template: " + text
}


function County(options) {

  // Self Reference for inner function contexts
  var self = this;


  // Set provided options as class properties
  this.container = options.container;
  this.csv = options.csv;

  if (!this.csv) {
    error("No data csv provided to map!");
  }

  // Attempt to get csv
  d3.csv(this.csv, function(error, data) {
    console.log(data);
  });

}

County.prototype.render = function() {

};

}).call(this)