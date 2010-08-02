# GVPDFView.rb
# Leonhard
#
# Created by greg on 30/07/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

class GVPDFView < PDFView
  def printDocument(sender)
    # Let PDFView handle the printing.
    super.printWithInfo( NSPrintInfo.sharedPrintInfo, autoRotate:true, pageScaling:2 )
    return;
  end
end