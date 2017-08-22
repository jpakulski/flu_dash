import Ember from 'ember';

export default Ember.Component.extend({
  height: 200,
  width: 500,
  interpolation: 'linear',
  data: [],
  yAxisWidth: 30.5,
  xAxisHeight: 20.5,
  topMargin: 5.5,
  hasSelect: true,
  xTicks: 7,
  yTicks: 4,

  yAxisTransform: (function() {
    return 'translate(' + this.get('yAxisWidth') + ', 0)';
  }).property(),

  didInsertElement: function() {
    var sectionWidth = this.$().closest('section').width();
    this.set('width', sectionWidth);
    this.resetSelection();
    this.updateAxis();
    this.updateBrush();
  },

  updateBrush: function() {
    if (this.get('hasSelect')) {
      d3.select(this.$('.brush.x')[0])
        .call(this.get('brush'))
        .selectAll('rect')
        .attr('y', -2)
        .attr('height', this.get('height') + 4);
    }
  },

  resetSelection: function() {
    var extent = d3.extent( this.get('data'), function(d) { return new Date(d.x) });
    this.set('selectedFrom', extent[0]);
    this.set('selectedTo', extent[1]);
  },

  brush: (function() {
    var _this = this;
    return d3
      .svg.brush()
      .x(this.get('x'))
      .on('brush', function() {
        var extent = _this.get('brush').extent();
        if (extent[0].getTime() == extent[1].getTime()) {
          _this.resetSelection();
        } else {
          Ember.run.next(this, function() {
            _this.set('selectedFrom', extent[0]);
            _this.set('selectedTo', extent[1]);
          });
        }
      })
  }).property('x', 'data'),

  yAxis: (function() {
    return d3
      .svg
      .axis()
      .scale(this.get('y'))
      .orient('left')
      .ticks(this.get('yTicks'))
      .tickSize(-this.get('width') + this.get('yAxisWidth') * 2, 0);
  }).property('y'),

  xAxis: (function() {
    return d3
      .svg
      .axis()
      .scale(this.get('x'))
      .orient('bottom')
      .ticks(this.get('xTicks'))
      .tickSize(-this.get('height') + this.get('xAxisHeight') + this.get('topMargin') - 1, 0);
  }).property('x'),

  xAxisTransform: (function() {
    return 'translate(0, ' + (this.get('height') - this.get('xAxisHeight')) + ')';
  }).property('height'),

  dataDidChange: (function() {
    this.updateAxis();
    this.updateBrush();
  }).observes('data'),

  updateAxis: function() {
    d3.select(this.$('.axis.x')[0])
      .call(this.get('xAxis'))
      .selectAll('text')
      .attr('transform', 'translate(0, 7)');

    d3.select(this.$('.axis.y')[0])
      .call(this.get('yAxis'))
      .selectAll('text')
      .attr('transform', 'translate(-7, 0)');
  },

  x: (function() {
    var yAxisWidth = this.get('yAxisWidth');
    return d3
      .time
      .scale()
      .range([yAxisWidth, this.get('width') - yAxisWidth])
      .domain(d3.extent(this.get('data'), function(d) { return new Date(d.x) }));
  }).property('data', 'width'),

  y: (function() {
    var topMargin = this.get('topMargin'),
        xAxisHeight = this.get('xAxisHeight');
    return d3
      .scale
      .linear()
      .range([this.get('height') - xAxisHeight - 1, topMargin])
      .domain(d3.extent(this.get('data'), function(d) { return d.y }));
  }).property('data', 'height'),

  line: (function() {
    var x = this.get('x'),
        y = this.get('y'),
        data = this.get('data'),
        interpolation = this.get('interpolation');

    return d3.svg.line()
      .x(function(d) {
        return x(new Date(d.x));
      })
      .y(function(d) {
        return y(d.y);
      })
      .interpolate(interpolation)(data);
  }).property('x', 'y', 'data', 'interpolation')
});
