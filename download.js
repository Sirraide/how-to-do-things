// How to download data from the browser
function download(what, mime = 'text/plain') {
	let a = document.createElement('a')
	a.setAttribute('href', `data:${mime};charset=utf-8,` + encodeURIComponent(what))
	a.setAttribute('download', 'download')
	a.style.display = 'none'

	document.body.append(a)
	a.click()
	a.remove()
}
