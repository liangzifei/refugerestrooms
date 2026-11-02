import { Maps } from '../../lib/maps';

let URLParamsParser = window.URLSearchParams;

// Polyfill for old browsers.
if (!URLParamsParser) {
  URLParamsParser = function (locationSearch) {
    this.get = (key) => this.queryParams[key];
    this.queryParams = locationSearch
      .slice(1)
      .split('&')
      .map(param => param.split('='))
      .reduce((acc, value) => {
        return acc.concat(value);
      }, [])
      .reduce((acc, currValue, currIdx, ary) => {
        if(currIdx % 2 == 0) {
          acc[currValue] = ary[currIdx + 1];
        }
        return acc;
      }, {});
  }
}

$(function(){
  function getSearchParams() {
    const { search: search } = location;
    return new URLParamsParser(search);
  }

  if (getSearchParams().get('view') == 'map') {
    $("#list").hide();
    $.get('/restrooms' + window.location.search , {}, (points) => {
      // Default to the first report, or New York City, when no location was searched.
      const first = points && points.length ? points[0] : null;
      const lat = getSearchParams().get('lat') || (first && first.latitude) || 40.7128;
      const long = getSearchParams().get('long') || (first && first.longitude) || -74.0060;

      Maps.loadMapWithPoints(lat, long, points);
      $("#mapContainer").fadeIn(500);
    }, 'json');
  } else {
    $("#mapContainer").hide();
  }
});
