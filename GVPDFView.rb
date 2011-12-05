# GVPDFView.rb
# Leonhard
#
# Created by greg on 30/07/10.
# Copyright 2010, 2011 Gregoire Lejeune. All rights reserved.

class GVPDFView < PDFView
  def printDocument(sender)
    printInfo = NSPrintInfo.sharedPrintInfo
    printInfo.topMargin = 0.0
    printInfo.bottomMargin = 0.0
    printInfo.leftMargin = 0.0
    printInfo.rightMargin = 0.0
    printInfo.horizontallyCentered = true
    printInfo.verticallyCentered = true
    printInfo.horizontalPagination = NSFitPagination
    printInfo.verticalPagination = NSFitPagination
    myop = NSPrintOperation.printOperationWithView(self.documentView, printInfo:printInfo)
    myop.runOperation
    return
  end
end