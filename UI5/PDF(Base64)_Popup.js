//Display Base64 PDF in Popup
showPdfPopup: function(Base64Pdf) {
    var base64EncodedPDF = Base64Pdf;
    var decodedPdfContent = atob(base64EncodedPDF);
    var byteArray = new Uint8Array(decodedPdfContent.length);
    for (var i = 0; i < decodedPdfContent.length; i++) {
        byteArray[i] = decodedPdfContent.charCodeAt(i);
    }
    var blob = new Blob([byteArray.buffer], {
        type: 'application/pdf'
    });
    var _pdfurl = URL.createObjectURL(blob);
    this._PDFViewer = new sap.m.PDFViewer({
        title: "Title",
        source: _pdfurl,
        width:"50%",
        showDownloadButton: false
    });
    jQuery.sap.addUrlWhitelist("blob");

    this._PDFViewer.open();
}

//Call method
this.showPdfPopup("your base64 string" );