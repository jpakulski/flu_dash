import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['pie-chart'],
  height: 200,
  width: 500,
  outerRadius: 100,
  innerRadius: 50,
  data: [],
  colors: ['#3b9bcc', '#3bcc78', '#3ba4cc', '#3bbbcc', '#3bccba', '#3bcc97'],

  didInsertElement: function() {
    var data = this.get('data'),
        pie = this.get('pie'),
        color = this.get('color'),
        arc = this.get('arc'),
        g = d3.select(this.$('svg g')[0])
            .selectAll('.arc')
            .data(pie(data))
            .enter()
            .append('g')
            .attr('class', 'arc');

    g.append('path')
      .attr('d', arc)
      .style('fill', function(d) {
        return color(d.data.x);
      })
      .each(function(d) { return this._current = d; });

    var labels = g.append('text')
      .attr('transform', function(d) { return 'translate(' + arc.centroid(d) + ')'; })
      .attr('dy', '.35em')
      .style('text-anchor', 'middle')
      .text(function(d) {
        var label = '';
        if(d.data.y > 0) {
          label = d.data.x;
        }
        return label;
      });

    this.set('labels', labels);
    this.set('segments', g);
  },

  isValid: (function() {
    var data = this.get('data');
    return data && !data.isEvery('y', 0);
  }).property('data'),

  selectedDateRangeDidChange: (function() {
    this.update();
  }).observes('data'),

  update: function() {
    if (!this.get('isValid')) {
      return;
    }

    var data = this.get('data'),
        pie = this.get('pie'),
        segments = this.get('segments'),
        arc = this.get('arc'),
        labels = this.get('labels'),
        tween = this.get('tween'),
        _this = this;

    var path = segments.data(pie(data)).select('path');
    path.transition()
    .duration(500)
    .attrTween('d', function(d, i) {
      labels.remove();
      return tween(path[0][i], d, arc);
    })
    .each('end', function(d, i) {
      if (i == segments.length - 1) {
        labels = segments.append('text')
          .attr('transform', function(d) { return 'translate(' + arc.centroid(d) + ')'; })
          .attr('dy', '.35em')
          .style('text-anchor', 'middle')
          .text(function(d) {
            var label = '';
            if(d.data.y > 0) {
              label = d.data.x;
            }
            return label;
          });
        _this.set('labels', labels);
      }
    });
  },

  pieTransform: (function() {
    return 'translate(' + this.get('width') / 2 + ', ' + this.get('height') / 2 + ')';
  }).property('width', 'height'),

  color: (function() {
    return d3
      .scale
      .ordinal()
      .range(this.get('colors'));
  }).property('colors'),

  arc: (function() {
    return d3
      .svg
      .arc()
      .outerRadius(this.get('outerRadius') - 10)
      .innerRadius(this.get('innerRadius'));
  }).property(),

  pie: (function() {
    return d3
      .layout
      .pie()
      .sort(null)
      .value(function(d) {
        return d.y;
      });
  }).property(),

  tween: function(path, d, arc) {
    var i = d3.interpolate(path._current, d);
    path._current = i(0);
    return function(t) {
      return arc(i(t));
    }
  }
});
