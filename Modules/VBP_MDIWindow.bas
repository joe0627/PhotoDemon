Attribute VB_Name = "MDI_Handler"
'***************************************************************************
'MDI Window Handler
'Copyright �2000-2012 by Tanner Helland
'Created: 11/29/02
'Last updated: 10/September/12
'Last update: when calling FitOnScreen, maximized forms are now left maximized (previously they were forceably un-maximized)
'
'Interfaces with the main MDI active form; this module handles determining
'form size in relation to image size, etc.
'
'***************************************************************************

Option Explicit

'The image number PhotoDemon is currently at (always goes up, never down; starts at zero when the program is loaded)
Public NumOfImagesLoaded As Long

'The current image we are working with (generally FormMain.ActiveForm.Tag)
Public CurrentImage As Long

'Number of existing windows (goes up or down as images are opened or closed)
Public NumOfWindows As Long

'This array holds ALL IMPORTANT IMAGE INFORMATION for every loaded image.
'Undo functionality also exists only within these classes.
Public pdImages() As pdImage

'Create a new, blank MDI child
Public Sub CreateNewImageForm(Optional ByVal forInternalUse As Boolean = False)

    'Disable viewport adjustments
    FixScrolling = False

    'Increase the number of images we're tracking
    NumOfImagesLoaded = NumOfImagesLoaded + 1
    ReDim Preserve pdImages(0 To NumOfImagesLoaded) As pdImage
    
    Set pdImages(NumOfImagesLoaded) = New pdImage

    'This is the actual, physical form object on which an image will reside
    Dim frm As New FormImage
    
    'IMPORTANT: the form tag is the only way we can keep track of separate forms
    'DO NOT CHANGE THIS TAG VALUE!
    frm.Tag = NumOfImagesLoaded
    
    'Remember this ID in the associated image class
    pdImages(NumOfImagesLoaded).IsActive = True
    pdImages(NumOfImagesLoaded).imageID = NumOfImagesLoaded
        
    'Default size (stupid twip measurements, unfortunately)
    frm.Width = 4500
    
    frm.Height = 1
    
    'Default image values
    Set pdImages(NumOfImagesLoaded).containingForm = frm
    pdImages(NumOfImagesLoaded).UndoNum = 0
    pdImages(NumOfImagesLoaded).UndoMax = 0
    pdImages(NumOfImagesLoaded).UndoState = False
    pdImages(NumOfImagesLoaded).RedoState = False
    pdImages(NumOfImagesLoaded).CurrentZoomValue = zoomIndex100   'Default zoom is 100%
    
    'This is kind of cheap, but let's just set a random loading point between 0 and 99% :)
    Randomize Timer
    Dim RandPercent As Long
    RandPercent = Int(Rnd * 100)
    
    'Hide the form off-screen while the loading takes place, but remember its location so we can restore it post-load.
    pdImages(NumOfImagesLoaded).WindowLeft = frm.Left
    pdImages(NumOfImagesLoaded).WindowTop = frm.Top
    frm.Left = FormMain.ScaleWidth
    frm.Top = FormMain.ScaleHeight
    
    frm.Show
    frm.Caption = "Loading image (" & RandPercent & "%)..."
    If FormMain.Enabled Then frm.SetFocus
    
    'Set this image as the current one
    CurrentImage = NumOfImagesLoaded
    
    'Track how many windows we currently have open
    NumOfWindows = NumOfWindows + 1
    
    'Run a separate subroutine (see bottom of this page) to enable/disable menus and such if this is the first image to be loaded
    UpdateMDIStatus
    
    'Re-enable viewport adjustments
    FixScrolling = True
    
    'If this image wasn't loaded by the user (e.g. it's an internal PhotoDemon process), mark is as such
    pdImages(NumOfImagesLoaded).forInternalUseOnly = forInternalUse
    
End Sub

'Fit the active window tightly around the image
Public Sub FitWindowToImage(Optional ByVal suppressRendering As Boolean = False, Optional ByVal isImageLoading As Boolean = False)
        
    If NumOfWindows = 0 Then Exit Sub
        
    'Make sure the window isn't minimized or maximized
    If FormMain.ActiveForm.WindowState = 0 Then
    
        'Disable AutoScroll, because that messes with our calculations
        FixScrolling = False
    
        'To minimize flickering, we will only apply width/height and top/left changes once.
        ' While calculations are being run, store all changes to variables.
        Dim curTop As Long, curLeft As Long
        Dim curWidth As Long, curHeight As Long
    
        'Because certain changes will trigger the appearance of scroll bars, which take up extra space in the viewport,
        ' we need to check for this and potentially increase window size slightly to accomodate the scroll bars.
        Dim forceMaxWidth As Boolean, forceMaxHeight As Boolean
        forceMaxWidth = False
        forceMaxHeight = False
    
        'Change the scalemode to twips to match the MDI form
        FormMain.ActiveForm.ScaleMode = 1
    
        'Now let's get some dimensions for our calculations
        Dim wDif As Long, hDif As Long
        'This variable determines the difference between scalewidth and width...
        wDif = FormMain.ActiveForm.Width - FormMain.ActiveForm.ScaleWidth
        '...while this variable does the same thing for scaleheight and height
        hDif = FormMain.ActiveForm.Height - FormMain.ActiveForm.ScaleHeight
        
        'Now we set the form dimensions to match the image's
        curWidth = wDif + ((Screen.TwipsPerPixelX * pdImages(CurrentImage).Width) * Zoom.ZoomArray(FormMain.CmbZoom.ListIndex))
        curHeight = hDif + ((Screen.TwipsPerPixelY * pdImages(CurrentImage).Height) * Zoom.ZoomArray(FormMain.CmbZoom.ListIndex))
        
        'There is a possibility that after a transformation (such as a rotation), part of the image may be off the screen.
        ' Start by populating some coordinate variables, which will be generated differently contingent on the image
        ' being a newly loaded one (and thus is still off-screen), or a presently visible one.
        If isImageLoading Then
            curLeft = pdImages(CurrentImage).WindowLeft
            curTop = pdImages(CurrentImage).WindowTop
        Else
            curLeft = FormMain.ActiveForm.Left
            curTop = FormMain.ActiveForm.Top
        End If
        
        ' Check for the image being off-viewport, starting with the vertical measurement.
        If curTop + curHeight > FormMain.ScaleHeight Then
        
            'If we can solve the problem by simply moving the form upward, do that.
            If curHeight < FormMain.ScaleHeight Then
                curTop = FormMain.ScaleHeight - curHeight
        
            'If the image is taller than the MDI client area, we have a problem.  Move the image to the top of the
            ' MDI client area, then shrink the window vertically to force a scroll bar appearance.
            Else
                curTop = 0
                curHeight = FormMain.ScaleHeight
                forceMaxHeight = True
            End If
        
        End If
       
        'Next, check the horizontal measurement.
        If curLeft + curWidth > FormMain.ScaleWidth Then
       
            'If we can solve the problem by simply moving the form left, do that.
            If curWidth < FormMain.ScaleWidth Then
                curLeft = FormMain.ScaleWidth - curWidth
       
            'If the image is wider than the MDI client area, we have a problem.  Move the image to the far left of the
            ' MDI client area, then shrink the window horizontally to force a scroll bar appearance.
            Else
                curLeft = 0
                curWidth = FormMain.ScaleWidth
                forceMaxWidth = True
            End If
       
        End If
        
        'If the image does not fill the entire viewport, but one dimension is maxed out, add a little extra space for
        ' the scroll bar that will necessarily appear.
        If forceMaxHeight And (Not forceMaxWidth) Then
            curWidth = curWidth + FormMain.ActiveForm.VScroll.Width
            
            'If this addition pushes the image off-screen, nudge it slightly left
            If curLeft + curWidth > FormMain.ActiveForm.ScaleWidth Then curLeft = curWidth
            
        End If
        
        If forceMaxWidth And (Not forceMaxHeight) Then
            curHeight = curHeight + FormMain.ActiveForm.HScroll.Height
            
            'If this addition pushes the image off-screen, nudge it slightly up
            If curTop + curHeight > FormMain.ActiveForm.ScaleHeight Then curTop = curHeight
            
        End If
        
        'Apply the changes in whatever manner appropriate (again, this is handled differently if the image is newly loaded)
        If isImageLoading Then
            pdImages(CurrentImage).WindowLeft = curLeft
            pdImages(CurrentImage).WindowTop = curTop
            FormMain.ActiveForm.Width = curWidth
            FormMain.ActiveForm.Height = curHeight
        Else
            FormMain.ActiveForm.Move curLeft, curTop, curWidth, curHeight
        End If
        
        'Set the scalemode back to a decent pixels
        FormMain.ActiveForm.ScaleMode = 3
    
        'Re-enable scrolling
        FixScrolling = True
        
    End If
    
    'Because external functions may rely on this to redraw the viewport, force a redraw regardless of whether or not
    ' the window was actually fit to the image (unless suppressRendering is specified, obviously)
    If suppressRendering = False Then PrepareViewport FormMain.ActiveForm, "FitWindowToImage"
    
End Sub

'Resize the window so that all four edges are within the current viewport.
Public Sub FitWindowToViewport(Optional ByVal suppressRendering As Boolean = False)
        
    If NumOfWindows = 0 Then Exit Sub
    
    Dim resizeNeeded As Boolean
    resizeNeeded = False
        
    'Make sure the window isn't minimized or maximized
    If FormMain.ActiveForm.WindowState = 0 Then
    
        'Prevent automatic recalculation of the viewport scroll bars until we finish our calculations here
        FixScrolling = False
        
        'Start by determining if the image's canvas falls outside the viewport area.  Note that we will repeat this process
        ' twice: once for horizontal, and again for vertical.
        If FormMain.ActiveForm.Left + FormMain.ActiveForm.Width > FormMain.ScaleWidth Then
            
            resizeNeeded = True
            
            'This variable determines the difference between the MDI client area's available width and the current child form's
            ' width, taking into account the .Left position and an arbitrary offset (currently 12 pixels)
            Dim newWidth As Long
            newWidth = FormMain.ScaleWidth - FormMain.ActiveForm.Left - (12 * Screen.TwipsPerPixelX)
            FormMain.ActiveForm.Width = newWidth
            
        End If
        
        'Now repeat the process for the vertical measurement
        If FormMain.ActiveForm.Top + FormMain.ActiveForm.Height > FormMain.ScaleHeight Then
        
            resizeNeeded = True
        
            Dim newHeight As Long
            newHeight = FormMain.ScaleHeight - FormMain.ActiveForm.Top - (12 * Screen.TwipsPerPixelY)
            FormMain.ActiveForm.Height = newHeight
            
        End If
            
        'Re-enable scrolling
        FixScrolling = True
        
    End If
    
    'Because external functions may rely on this to redraw the viewport, force a redraw regardless of whether or not
    ' the window was actually fit to the image (unless suppressRendering is specified, obviously)
    If (suppressRendering = False) And resizeNeeded Then PrepareViewport FormMain.ActiveForm, "FitWindowToViewport"
    
End Sub

'Fit the current image onscreen at as large a size as possible (but never larger than 100% zoom)
Public Sub FitImageToViewport(Optional ByVal suppressRendering As Boolean = False)
    
    If NumOfWindows = 0 Then Exit Sub
    
    'Disable AutoScroll, because that messes with our calculations
    FixScrolling = False
    
    'Gotta change the scalemode to twips to match the MDI form
    FormMain.ActiveForm.ScaleMode = 1
    
    'Make sure the window isn't minimized
    If FormMain.ActiveForm.WindowState = vbMinimized Then Exit Sub
    
    'Now let's get some dimensions for our calculations
    Dim tDif As Long, hDif As Long
    'This variable determines the difference between scalewidth and width...
    tDif = FormMain.ActiveForm.Width - FormMain.ActiveForm.ScaleWidth
    '...while this variable does the same thing for scaleheight and height
    hDif = FormMain.ActiveForm.Height - FormMain.ActiveForm.ScaleHeight
    
    'Use this to track zoom
    Dim zVal As Long
    zVal = zoomIndex100
    
    'First, let's check to see if we need to adjust zoom because the width is too big
    If (Screen.TwipsPerPixelX * pdImages(CurrentImage).Width) > (FormMain.ScaleWidth - tDif) Then
        'If it is too big, run a loop backwards through the possible zoom values to see
        'if one will make it fit
        For x = zoomIndex100 To Zoom.ZoomCount Step 1
            If (Screen.TwipsPerPixelX * pdImages(CurrentImage).Width * Zoom.ZoomArray(x)) < (FormMain.ScaleWidth - tDif) Then
                zVal = x
                Exit For
            End If
        Next x
        
    End If
    
    'Now we do the same thing for the height
    If (Screen.TwipsPerPixelY * pdImages(CurrentImage).Height) > (FormMain.ScaleHeight - hDif) Then
        'If the image's height is too big for the form, run a loop backwards through all
        ' possible zoom values to see if one will make it fit
        For x = zVal To Zoom.ZoomCount Step 1
            If (Screen.TwipsPerPixelY * pdImages(CurrentImage).Height * Zoom.ZoomArray(x)) < FormMain.ScaleHeight - hDif Then
                zVal = x
                Exit For
            End If
        Next x
        
    End If
    
    'Change the zoom combo box to reflect the new zoom value (or the default, if no changes were made)
    FormMain.CmbZoom.ListIndex = zVal
    pdImages(CurrentImage).CurrentZoomValue = zVal
    
    'Set the scalemode back to a decent value
    FormMain.ActiveForm.ScaleMode = 3
    
    'Re-enable scrolling
    FixScrolling = True
    
    'Now fix scrollbars and everything
    If suppressRendering = False Then PrepareViewport FormMain.ActiveForm, "FitImageToViewport"
    
End Sub

'Fit the current image onscreen at as large a size as possible (including possibility of zoomed-in)
Public Sub FitOnScreen()
    
    If NumOfWindows = 0 Then Exit Sub
    
    'Gotta change the scalemode to twips to match the MDI form
    FormMain.ActiveForm.ScaleMode = 1
        
    'Disable AutoScroll, because that messes with our calculations
    FixScrolling = False
    
    'If the image is minimized, restore it
    If FormMain.ActiveForm.WindowState = vbMinimized Then FormMain.ActiveForm.WindowState = 0
    
    'Now let's get some dimensions for our calculations
    Dim tDif As Long, hDif As Long
    'This variable determines the difference between scalewidth and width...
    tDif = FormMain.ActiveForm.Width - FormMain.ActiveForm.ScaleWidth
    '...while this variable does the same thing for scaleheight and height
    hDif = FormMain.ActiveForm.Height - FormMain.ActiveForm.ScaleHeight

    'Use this to track zoom
    Dim zVal As Long
    zVal = 0
    
    'Run a loop backwards through the possible zoom values to see
    'if one will make it fit at the maximum possible size
    For x = 0 To Zoom.ZoomCount Step 1
        If (Screen.TwipsPerPixelX * pdImages(CurrentImage).Width * Zoom.ZoomArray(x)) < FormMain.ScaleWidth - tDif Then
            zVal = x
            Exit For
        End If
    Next x
    
    'Now we do the same thing for the height
    For x = zVal To Zoom.ZoomCount Step 1
        If (Screen.TwipsPerPixelY * pdImages(CurrentImage).Height * Zoom.ZoomArray(x)) < FormMain.ScaleHeight - hDif Then
            zVal = x
            Exit For
        End If
    Next x
    FormMain.CmbZoom.ListIndex = zVal
    pdImages(CurrentImage).CurrentZoomValue = zVal
    
    'Set the scalemode back to pixels
    FormMain.ActiveForm.ScaleMode = 3
    
    'Re-enable scrolling
    FixScrolling = True
    
    'If the window is not maximized or minimized, fit the window to it
    If FormMain.ActiveForm.WindowState = 0 Then FitWindowToImage True
    
    'Now fix scrollbars and everything
    PrepareViewport FormMain.ActiveForm, "FitOnScreen"
    
End Sub

'When windows are created or destroyed, launch this routine to dis/en/able windows and toolbars, etc
Public Sub UpdateMDIStatus()

    'If two or more windows are open, enable the Next/Previous image menu items
    If NumOfWindows >= 2 Then
        FormMain.MnuNextImage.Enabled = True
        FormMain.MnuPreviousImage.Enabled = True
    Else
        FormMain.MnuNextImage.Enabled = False
        FormMain.MnuPreviousImage.Enabled = False
    End If

    'If every window has been closed, disable all toolbar and menu options that are no longer applicable
    If NumOfWindows < 1 Then
        tInit tFilter, False
        tInit tSave, False
        tInit tSaveAs, False
        tInit tCopy, False
        tInit tUndo, False
        tInit tRedo, False
        tInit tImageOps, False
        tInit tFilter, False
        tInit tMacro, False
        tInit tRepeatLast, False
        tInit tSelection, False
        FormMain.MnuClose.Enabled = False
        FormMain.MnuCloseAll.Enabled = False
        FormMain.cmdClose.Enabled = False
        FormMain.MnuFitWindowToImage.Enabled = False
        FormMain.MnuFitOnScreen.Enabled = False
        If FormMain.CmbZoom.Enabled = True Then
            FormMain.CmbZoom.Enabled = False
            FormMain.lblZoom.ForeColor = &H606060
            FormMain.CmbZoom.ListIndex = zoomIndex100   'Reset zoom to 100%
        End If
        
        FormMain.lblImgSize.ForeColor = &HD1B499
        FormMain.lblCoordinates.ForeColor = &HD1B499
        
        FormMain.lblImgSize.Caption = ""
        
        FormMain.lblCoordinates.Caption = ""
        
        Message "Please load an image.  (The large 'Open Image' button at the top-left should do the trick!)"
        
        'Finally, if dynamic icons are enabled, restore the main program icon and clear the icon cache
        If userPreferences.GetPreference_Boolean("General Preferences", "DynamicTaskbarIcon", True) Then
            destroyAllIcons
            setNewTaskbarIcon origIcon32
            setNewAppIcon origIcon16
        End If
        
        'New addition: destroy all inactive pdImage objects.  This helps keep memory usage at a bare minimum.
        If NumOfImagesLoaded > 1 Then
        
            Dim i As Long
            
            'Loop through all pdImage objects and make sure they've been deactivated
            For i = 0 To NumOfImagesLoaded
                If (Not pdImages(i) Is Nothing) Then
                    pdImages(i).deactivateImage
                    Set pdImages(i) = Nothing
                End If
            Next i
        
            'Redim the pdImages array
            Erase pdImages
        
            'Reset all window tracking variables
            NumOfImagesLoaded = 0
            CurrentImage = 0
            NumOfWindows = 0
                        
        End If
        
        'Erase any remaining viewport buffer
        eraseViewportBuffers
                
    'Otherwise, enable all of 'em
    Else
        tInit tFilter, True
        tInit tSave, True
        tInit tSaveAs, True
        tInit tCopy, True
        tInit tUndo, pdImages(CurrentImage).UndoState
        tInit tRedo, pdImages(CurrentImage).RedoState
        tInit tImageOps, True
        tInit tFilter, True
        tInit tMacro, True
        tInit tRepeatLast, pdImages(CurrentImage).RedoState
        FormMain.MnuClose.Enabled = True
        FormMain.cmdClose.Enabled = True
        FormMain.MnuCloseAll.Enabled = True
        FormMain.MnuFitWindowToImage.Enabled = True
        FormMain.MnuFitOnScreen.Enabled = True
        FormMain.lblImgSize.ForeColor = &H544E43
        FormMain.lblCoordinates.ForeColor = &H544E43
        If FormMain.CmbZoom.Enabled = False Then
            FormMain.CmbZoom.Enabled = True
            FormMain.lblZoom.ForeColor = &H544E43
        End If
    End If
    
End Sub
