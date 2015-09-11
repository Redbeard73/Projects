function zipcodeformat(zip){
	_zip = zip;
	_zip4 = '0000';
	if(zip.length == 9){
		_zip=zip.substr(0,5);
		_zip4=zip.substr(5,4);
	}
	_zip = _zip + '-' + _zip4;
	return _zip;
}

function addCommas(str)
{
	str += '';
	str = str.replace(/,/g, '')
	v = str.split('.');
	v1 = v[0];
	v2 = v.length > 1 ? '.' + v[1] : '';
	var rgx = /(\d+)(\d{3})/;
	while (rgx.test(v1)) {
		v1 = v1.replace(rgx, '$1' + ',' + '$2');
	}
	return v1 + v2;
}
  
function isNumeric(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}