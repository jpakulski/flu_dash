# Fly Dash

An Ember and D3 based dashboard.
Various quantities of data can be generated right in the client and consumed by the dashboard.

![Application screenshot](/screenshot_flu_dash.jpg)

## Why?

I used it briefly for testing / optimizing Ember chart components.

It may not win any design awards now but it did make a nice enough demo for a job interview several years ago.

## Install

```
git clone https://github.com/jpakulski/flu_dash.git
cd flu_dash
npm install && bower install
ember s
```

## Use

1. Select the amount of data to generate (default was 100 rows).
2. Click the "Regenerate X Rows of Data" button to regenerate the data.
3. Drag on the top chart to select a date range.
4. The detail section below will update in real-time based on the date range selected.
5. Click on the "Data" button in the top right corner to view the raw data. **Warning** The data grid is just a table. A million rows of data may not render all that happily.
