VERSION 5.00
Begin VB.Form FormBatchConvert 
   Appearance      =   0  'Flat
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   " Batch Convert Images"
   ClientHeight    =   8190
   ClientLeft      =   45
   ClientTop       =   315
   ClientWidth     =   12135
   BeginProperty Font 
      Name            =   "Tahoma"
      Size            =   8.25
      Charset         =   0
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   546
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   809
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin VB.OptionButton optActions 
      Appearance      =   0  'Flat
      Caption         =   "Apply the following macro to each image:"
      ForeColor       =   &H00800000&
      Height          =   495
      Index           =   1
      Left            =   8520
      TabIndex        =   39
      Top             =   960
      Width           =   3375
   End
   Begin VB.OptionButton optActions 
      Appearance      =   0  'Flat
      Caption         =   "Do not apply a macro.  (Use this if you just want to convert file formats.)"
      ForeColor       =   &H00800000&
      Height          =   495
      Index           =   0
      Left            =   8520
      TabIndex        =   38
      Top             =   480
      Value           =   -1  'True
      Width           =   3375
   End
   Begin VB.ComboBox cmbPattern 
      ForeColor       =   &H00800000&
      Height          =   315
      Left            =   240
      Style           =   2  'Dropdown List
      TabIndex        =   4
      Top             =   3240
      Width           =   3495
   End
   Begin VB.HScrollBar hsJpegQuality 
      Height          =   255
      Left            =   9840
      Max             =   100
      Min             =   1
      TabIndex        =   21
      Top             =   6120
      Value           =   92
      Width           =   1935
   End
   Begin VB.ComboBox cmbOutputFormat 
      ForeColor       =   &H00800000&
      Height          =   315
      Left            =   8520
      Style           =   2  'Dropdown List
      TabIndex        =   19
      Top             =   5640
      Width           =   3255
   End
   Begin VB.TextBox txtQuality 
      Alignment       =   2  'Center
      ForeColor       =   &H00800000&
      Height          =   300
      Left            =   9240
      TabIndex        =   20
      Text            =   "92"
      Top             =   6105
      Width           =   495
   End
   Begin VB.TextBox txtOutputPath 
      ForeColor       =   &H00800000&
      Height          =   285
      Left            =   8520
      TabIndex        =   15
      Text            =   "C:\"
      Top             =   3000
      Width           =   2775
   End
   Begin VB.CommandButton cmdSelectOutputPath 
      Caption         =   "..."
      Height          =   280
      Left            =   11400
      TabIndex        =   16
      Top             =   3000
      Width           =   375
   End
   Begin VB.TextBox txtAppendFront 
      ForeColor       =   &H00800000&
      Height          =   285
      Left            =   8520
      TabIndex        =   17
      Text            =   "NEW_"
      Top             =   3720
      Width           =   3255
   End
   Begin VB.ComboBox cmbOutputOptions 
      ForeColor       =   &H00800000&
      Height          =   315
      Left            =   8520
      Style           =   2  'Dropdown List
      TabIndex        =   18
      Top             =   4440
      Width           =   3255
   End
   Begin VB.TextBox txtMacro 
      Enabled         =   0   'False
      ForeColor       =   &H00800000&
      Height          =   285
      Left            =   8520
      TabIndex        =   13
      Text            =   "No macro selected"
      Top             =   1560
      Width           =   2775
   End
   Begin VB.CommandButton cmdSelectMacro 
      Caption         =   "..."
      Enabled         =   0   'False
      Height          =   280
      Left            =   11400
      TabIndex        =   14
      Top             =   1560
      Width           =   375
   End
   Begin VB.ListBox lstFiles 
      ForeColor       =   &H00800000&
      Height          =   4740
      Left            =   4080
      MultiSelect     =   2  'Extended
      TabIndex        =   8
      Top             =   840
      Width           =   3975
   End
   Begin VB.CommandButton cmdRemove 
      Caption         =   "Remove selected file(s)"
      Height          =   375
      Left            =   4080
      TabIndex        =   9
      Top             =   5760
      Width           =   1935
   End
   Begin VB.CommandButton cmdLoadList 
      Caption         =   "Load an image list..."
      Height          =   495
      Left            =   4080
      TabIndex        =   11
      Top             =   6720
      Width           =   1935
   End
   Begin VB.CommandButton cmdSaveList 
      Caption         =   "Save the current list..."
      Height          =   495
      Left            =   6120
      TabIndex        =   12
      Top             =   6720
      Width           =   1935
   End
   Begin VB.CommandButton cmdRemoveAll 
      Caption         =   "Remove all files"
      Height          =   375
      Left            =   6120
      TabIndex        =   10
      Top             =   5760
      Width           =   1935
   End
   Begin VB.DriveListBox Drive1 
      Appearance      =   0  'Flat
      ForeColor       =   &H00800000&
      Height          =   315
      Left            =   840
      TabIndex        =   2
      Top             =   480
      Width           =   2895
   End
   Begin VB.DirListBox Dir1 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
      ForeColor       =   &H00800000&
      Height          =   1665
      Left            =   240
      TabIndex        =   3
      Top             =   1200
      Width           =   3495
   End
   Begin VB.FileListBox File1 
      Appearance      =   0  'Flat
      ForeColor       =   &H00800000&
      Height          =   1785
      Left            =   240
      MultiSelect     =   2  'Extended
      Pattern         =   "*.jpg"
      TabIndex        =   5
      Top             =   3960
      Width           =   3495
   End
   Begin VB.CommandButton cmdAddFiles 
      Caption         =   "Add selected files to the batch list ->"
      Height          =   375
      Left            =   360
      TabIndex        =   6
      Top             =   5880
      Width           =   3255
   End
   Begin VB.CommandButton cmdUseCD 
      Caption         =   "Alternatively, you can use a Windows ""Common Dialog"" to select images..."
      Height          =   735
      Left            =   360
      TabIndex        =   7
      Top             =   6480
      Width           =   3255
   End
   Begin VB.CommandButton cmdCancel 
      Cancel          =   -1  'True
      Caption         =   "&Cancel"
      Height          =   495
      Left            =   10680
      TabIndex        =   1
      Top             =   7590
      Width           =   1215
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "&OK"
      Default         =   -1  'True
      Height          =   495
      Left            =   9360
      TabIndex        =   0
      Top             =   7590
      Width           =   1215
   End
   Begin VB.Label lblDisclaimer 
      BackStyle       =   0  'Transparent
      Caption         =   $"VBP_FormBatchConvert.frx":0000
      ForeColor       =   &H00800000&
      Height          =   855
      Left            =   8400
      TabIndex        =   37
      Top             =   6480
      Width           =   3495
   End
   Begin VB.Label lblOutputFolder 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   "Output images to this folder:"
      ForeColor       =   &H00400000&
      Height          =   195
      Left            =   8520
      TabIndex        =   36
      Top             =   2760
      Width           =   2070
   End
   Begin VB.Line Line5 
      BorderColor     =   &H80000002&
      X1              =   792
      X2              =   16
      Y1              =   496
      Y2              =   496
   End
   Begin VB.Line Line4 
      BorderColor     =   &H80000002&
      X1              =   792
      X2              =   560
      Y1              =   336
      Y2              =   336
   End
   Begin VB.Label lblStep5 
      BackStyle       =   0  'Transparent
      Caption         =   "Step 5 - Select Output Image Format:"
      BeginProperty Font 
         Name            =   "Tahoma"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00400000&
      Height          =   255
      Left            =   8520
      TabIndex        =   35
      Top             =   5280
      Width           =   3495
   End
   Begin VB.Label lblQuality 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   "Quality:"
      ForeColor       =   &H00400000&
      Height          =   195
      Left            =   8520
      TabIndex        =   34
      Top             =   6150
      Width           =   570
   End
   Begin VB.Line Line2 
      BorderColor     =   &H80000002&
      X1              =   792
      X2              =   560
      Y1              =   144
      Y2              =   144
   End
   Begin VB.Label lblStep4 
      BackStyle       =   0  'Transparent
      Caption         =   "Step 4 - Select Output Location:"
      BeginProperty Font 
         Name            =   "Tahoma"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00400000&
      Height          =   255
      Left            =   8520
      TabIndex        =   33
      Top             =   2400
      Width           =   3495
   End
   Begin VB.Label Label2 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   "Optional text to append to start of filenames:"
      ForeColor       =   &H00400000&
      Height          =   195
      Left            =   8520
      TabIndex        =   32
      Top             =   3480
      Width           =   3285
   End
   Begin VB.Label Label3 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   "Output image files should be named using:"
      ForeColor       =   &H00400000&
      Height          =   195
      Left            =   8520
      TabIndex        =   31
      Top             =   4200
      Width           =   3045
   End
   Begin VB.Line Line1 
      BorderColor     =   &H80000002&
      X1              =   552
      X2              =   552
      Y1              =   8
      Y2              =   488
   End
   Begin VB.Label lblStep3 
      BackStyle       =   0  'Transparent
      Caption         =   "Step 3 - Select Macro to Apply:"
      BeginProperty Font 
         Name            =   "Tahoma"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00400000&
      Height          =   255
      Left            =   8520
      TabIndex        =   30
      Top             =   120
      Width           =   3495
   End
   Begin VB.Label lblListManagement 
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Caption         =   "Export/import image lists:"
      ForeColor       =   &H00400000&
      Height          =   195
      Left            =   4080
      TabIndex        =   29
      Top             =   6360
      Width           =   1830
   End
   Begin VB.Label lblStep2 
      BackStyle       =   0  'Transparent
      Caption         =   "Step 2 - Verify List of Images:"
      BeginProperty Font 
         Name            =   "Tahoma"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00400000&
      Height          =   255
      Left            =   4080
      TabIndex        =   28
      Top             =   120
      Width           =   3495
   End
   Begin VB.Label Label1 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   "The following image files will be processed:"
      ForeColor       =   &H00400000&
      Height          =   255
      Left            =   4080
      TabIndex        =   27
      Top             =   480
      Width           =   3855
   End
   Begin VB.Line Line3 
      BorderColor     =   &H80000002&
      X1              =   256
      X2              =   256
      Y1              =   8
      Y2              =   488
   End
   Begin VB.Label lblStep1 
      BackStyle       =   0  'Transparent
      Caption         =   "Step 1 - Select Source Images:"
      BeginProperty Font 
         Name            =   "Tahoma"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00400000&
      Height          =   255
      Left            =   240
      TabIndex        =   26
      Top             =   120
      Width           =   3495
   End
   Begin VB.Label lblDrive 
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Caption         =   "Drive:"
      ForeColor       =   &H00400000&
      Height          =   195
      Left            =   240
      TabIndex        =   25
      Top             =   525
      Width           =   435
   End
   Begin VB.Label lblFolder 
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Caption         =   "Folder:"
      ForeColor       =   &H00400000&
      Height          =   195
      Left            =   240
      TabIndex        =   24
      Top             =   960
      Width           =   510
   End
   Begin VB.Label lblFiles 
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Caption         =   "Image Files (multi-select using Shift or Ctrl):"
      ForeColor       =   &H00400000&
      Height          =   195
      Left            =   240
      TabIndex        =   23
      Top             =   3720
      Width           =   3135
   End
   Begin VB.Label lblPattern 
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Caption         =   "Image Format:"
      ForeColor       =   &H00400000&
      Height          =   195
      Left            =   240
      TabIndex        =   22
      Top             =   3000
      Width           =   1065
   End
End
Attribute VB_Name = "FormBatchConvert"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'***************************************************************************
'Batch Conversion Form
'Copyright �2000-2012 by Tanner Helland
'Created: 3/Nov/07
'Last updated: 08/September/12
'Last update: rewrote all batch conversion file format compatibility against the new hybrid FreeImage/GDI+ system.  This means additional
'              file formats are available to non-FreeImage users (including PNG and TIFF!).
'
'Convert any number of files using any recorded macro.  Fast, impressive, bravo.
'
'***************************************************************************

Option Explicit

'Macro to perform on the batched images
Dim LocationOfMacroFile As String

'For now, we don't launch the typical file save options.  That's coming.  At present, track JPEG specifically since it
' is the only format with user-settable options.
Dim jpegFormatIndex As Long


'When the user changes the output file format, update relevant controls (for example, JPEG provides a scrollbar for setting encode quality)
Private Sub cmbOutputFormat_Click()
    UpdateVisibleControls
End Sub

Private Sub cmbOutputFormat_KeyDown(KeyCode As Integer, Shift As Integer)
    UpdateVisibleControls
End Sub

'Update the file list box to display only images of the selected file format
Private Sub cmbPattern_Click()
    File1.Pattern = imageFormats.getInputFormatExtensions(cmbPattern.ListIndex)
End Sub

Private Sub cmbPattern_KeyUp(KeyCode As Integer, Shift As Integer)
    File1.Pattern = imageFormats.getInputFormatExtensions(cmbPattern.ListIndex)
End Sub

Private Sub cmbPattern_Scroll()
    File1.Pattern = imageFormats.getInputFormatExtensions(cmbPattern.ListIndex)
End Sub

'Adds selected files from the left list box to the center list box
Private Sub cmdAddFiles_Click()
    For x = 0 To File1.ListCount - 1
        If File1.Selected(x) = True Then lstFiles.AddItem Dir1.Path & "\" & File1.List(x)
    Next x
End Sub

'CANCEL button
Private Sub CmdCancel_Click()
    Unload Me
End Sub

'Load a list of images (previously saved from within PhotoDemon) into the center list box
Private Sub cmdLoadList_Click()
    
    Dim sFile As String
    
    'Get the last "open/save image list" path from the INI file
    Dim tempPathString As String
    tempPathString = userPreferences.GetPreference_String("Batch Preferences", "ListFolder", "")
    
    Dim CC As cCommonDialog
    Set CC = New cCommonDialog
    
    If CC.VBGetOpenFileName(sFile, , True, False, False, True, "Batch Image List (.pdl)|*.pdl|All files|*.*", 0, tempPathString, "Load a list of images", ".pdl", FormBatchConvert.hWnd, OFN_HIDEREADONLY) Then
        
        'Save this new directory as the default path for future usage
        Dim listPath As String
        listPath = sFile
        StripDirectory listPath
        userPreferences.SetPreference_String "Batch Preferences", "ListFolder", listPath
        
        Dim fileNum As Integer
        fileNum = FreeFile
    
        Open sFile For Input As #fileNum
            Dim tmpLine As String
            Input #fileNum, tmpLine
            If tmpLine <> ("<" & PROGRAMNAME & " BATCH CONVERSION LIST>") Then
                MsgBox "This is not a valid list of images. Please try a different file.", vbExclamation + vbApplicationModal + vbOKOnly, "Invalid list file"
                Exit Sub
            End If
            
            'Check to see if the user wants to append this list to the current list,
            ' or if they want to load just the list data
            If lstFiles.ListCount > 0 Then
                Dim ret As VbMsgBoxResult
                ret = MsgBox("You have already created a list of images for processing. Would you like to replace the current list with the entries from this file? (Selecting 'no' will only append the entries from the file to the existing list.)", vbYesNo + vbApplicationModal + vbExclamation, "Append or replace existing files?")
                If ret = vbYes Then lstFiles.Clear
            End If
            
            'Now that everything is in place, load the entries from the file
            Input #fileNum, tmpLine
            Dim numOfEntries As Long
            numOfEntries = CLng(tmpLine)
            For x = 0 To numOfEntries - 1
                Input #fileNum, tmpLine
                lstFiles.AddItem tmpLine
            Next x
        Close #fileNum
    End If
    
End Sub

'Remove an item from the batch conversion list
Private Sub cmdRemove_Click()
    x = 0
    Do While x <= lstFiles.ListCount - 1
        If lstFiles.Selected(x) = True Then
            lstFiles.RemoveItem x
            x = x - 1
        Else
            x = x + 1
        End If
    Loop
End Sub

'Remove all items from the batch conversion list
Private Sub cmdRemoveAll_Click()
    lstFiles.Clear
End Sub

'Save the current list of images to be processed to a text file
Private Sub cmdSaveList_Click()
    
    'First, make sure some images have been placed in the list
    If lstFiles.ListCount < 1 Then
        MsgBox "You haven't selected any image files.  Please add one or more image files to the conversion list before attempting to save the list to file." & vbCrLf & vbCrLf & "Note: this is done by using the tools under the ""Step 1 - Select Source Images"" label.", vbExclamation + vbOKOnly + vbApplicationModal, "Empty image list"
        Exit Sub
    End If
    
    Dim sFile As String
    
    'Get the last "open/save image list" path from the INI file
    Dim tempPathString As String
    tempPathString = userPreferences.GetPreference_String("Batch Preferences", "ListFolder", "")
    
    Dim CC As cCommonDialog
    Set CC = New cCommonDialog
    
    If CC.VBGetSaveFileName(sFile, , True, "Batch Image List (.pdl)|*.pdl|All files|*.*", 0, tempPathString, "Save the current list of images", ".pdl", FormBatchConvert.hWnd, OFN_HIDEREADONLY) Then
        
        'Save this new directory as the default path for future usage
        Dim listPath As String
        listPath = sFile
        StripDirectory listPath
        userPreferences.SetPreference_String "Batch Preferences", "ListFolder", listPath
        
        If FileExist(sFile) Then Kill sFile
        Dim fileNum As Integer
        fileNum = FreeFile
        
        Open sFile For Output As #fileNum
            Print #fileNum, "<" & PROGRAMNAME & " BATCH CONVERSION LIST>"
            Print #fileNum, Trim(CStr(lstFiles.ListCount))
            For x = 0 To lstFiles.ListCount - 1
                Print #fileNum, lstFiles.List(x)
            Next x
            Print #fileNum, "<END OF LIST>"
        Close #fileNum
    End If
End Sub

'Open a common-dialog box and allow the user to select a macro file to use in the batch conversion
Private Sub cmdSelectMacro_Click()
    
    'Automatically launch the load Macro data routine
    Dim CC As cCommonDialog
    Dim sFile As String
    Set CC = New cCommonDialog
    
    'Get the last macro-related path from the INI file
    Dim tempPathString As String
    tempPathString = userPreferences.GetPreference_String("Program Paths", "Macro", "")
   
    'If we get a path, load that file
    If CC.VBGetOpenFileName(sFile, , , , , True, PROGRAMNAME & " Macro Data (." & MACRO_EXT & ")|*." & MACRO_EXT & "|All files|*.*", , tempPathString, "Open Macro File", "." & MACRO_EXT, FormMain.hWnd, OFN_HIDEREADONLY) Then
        'Save the new directory as the default path for future usage
        tempPathString = sFile
        StripDirectory tempPathString
        userPreferences.SetPreference_String "Program Paths", "Macro", tempPathString
        
        'Remember this path for the other routines
        LocationOfMacroFile = sFile
        txtMacro.Text = LocationOfMacroFile
    End If
    
End Sub

'OK button
Private Sub CmdOK_Click()
    
    'Make sure the user has selected some files to operate on
    If lstFiles.ListCount < 1 Then
        MsgBox "You haven't selected any image files.  Please add one or more image files to the conversion list before continuing." & vbCrLf & vbCrLf & "Note: this is done by using the tools under the ""Step 1 - Select Source Images"" label.", vbExclamation + vbOKOnly + vbApplicationModal, "No image files selected"
        Exit Sub
    End If
    
    'Ensure that the macro text box has a macro file loaded
    If optActions(1).Value = True And ((txtMacro.Text = "No macro selected") Or (txtMacro.Text = "")) Then
        MsgBox "Please select a valid macro file (Step 3!).", vbExclamation + vbOKOnly + vbApplicationModal, "No macro file selected"
        AutoSelectText txtMacro
        Exit Sub
    End If
    
    'If the user is saving a JPEG file, make sure that the quality value is acceptable
    If cmbOutputFormat.ListIndex = jpegFormatIndex Then
        If Not EntryValid(txtQuality, hsJpegQuality.Min, hsJpegQuality.Max) Then
            AutoSelectText txtQuality
            Exit Sub
        End If
    End If
    
    Me.Visible = False
    
    'Before doing anything, save relevant options to the INI file
    userPreferences.SetPreference_String "Batch Preferences", "DriveBox", Drive1
    userPreferences.SetPreference_String "Batch Preferences", "InputFolder", Dir1.Path

    'Let the rest of the program know that batch processing has begun
    MacroStatus = MacroBATCH
    
    Dim curBatchFile As Long
    Dim tmpFilename As String
    
    Dim totalNumOfFiles As Long
    totalNumOfFiles = lstFiles.ListCount
    
    'PreLoadImage requires an array.  This array will be used to send it individual filenames
    Dim sFile(0) As String
    
    'This is the folder we'll be saving images to
    Dim outputPath As String
    outputPath = txtOutputPath
    If Right(outputPath, 1) <> "\" Then outputPath = outputPath & "\"
    If DirectoryExist(outputPath) = False Then MkDir outputPath
    
    'This routine has the power to reappropriate use of the progress bar for itself.  Progress bar and message calls
    ' anywhere else in the project will be ignored while batch conversion is running.
    cProgBar.Max = totalNumOfFiles
    
    'Let's also give the user an estimate of how long this is going to take.  We'll estimate time by determining an
    ' approximate "time-per-image" value, then multiplying that by the amount of time remaining.  The progress bar
    ' will display this, automatically updated, as each image is completed.
    Dim timeStarted As Single, timeElapsed As Single, timeRemaining As Single, timePerFile As Single
    Dim numFilesProcessed As Long, numFilesRemaining As Long
    Dim minutesRemaining As Long, secondsRemaining As Long
    Dim timeMsg As String
    timeStarted = GetTickCount
    timeMsg = ""
    
    'This is where the fun begins.  Loop through every file in the list, processing them one-by-one
    For curBatchFile = 0 To totalNumOfFiles
    
        If MacroStatus = MacroCANCEL Then GoTo MacroCanceled
    
        tmpFilename = lstFiles.List(curBatchFile)
        
        'Give the user a progress update
        MacroMessage = "(Batch converting file #" & (curBatchFile + 1) & " of " & totalNumOfFiles & ")" & timeMsg
        cProgBar.Text = MacroMessage
        cProgBar.Value = curBatchFile
        
        'As a failsafe, check to make sure the current input file exists before attempting to load it
        If FileExist(tmpFilename) = True Then
            
            sFile(0) = tmpFilename
            
            'Check to see if the image file is a multipage file
            Static howManyPages As Long
            
            howManyPages = isMultiImage(tmpFilename)
            
            'Check the user's preference regarding multipage images.  If they have specifically requested that we load
            ' only the first page of the image, ignore any subsequent pages.
            If howManyPages > 0 Then
                If userPreferences.GetPreference_Long("General Preferences", "MultipageImagePrompt", 0) = 1 Then howManyPages = 1
            Else
                howManyPages = 1
            End If
            
            'Now, loop through each page or frame (if applicable), load the image, and process it.
            Static curPage As Long
            For curPage = 0 To howManyPages - 1
            
                'Load the current image
                PreLoadImage sFile, False, , , , , , curPage
            
                'If the user has requested a macro, play it now
                If optActions(1).Value = True Then PlayMacroFromFile LocationOfMacroFile
            
                'With the macro complete, prepare the file for saving
                tmpFilename = lstFiles.List(curBatchFile)
                StripOffExtension tmpFilename
                StripFilename tmpFilename
            
                'Build a full file path using the options the user specified
                If cmbOutputOptions.ListIndex = 0 Then
                    tmpFilename = outputPath & txtAppendFront & tmpFilename
                Else
                    tmpFilename = outputPath & txtAppendFront & (curBatchFile + 1)
                End If
                
                'Add the page number if necessary
                If curPage > 0 Then tmpFilename = tmpFilename & " (" & curPage & ")"
                
                'Attach the proper image format extension
                tmpFilename = tmpFilename & "." & imageFormats.getOutputFormatExtension(cmbOutputFormat.ListIndex)
                
                'Certain file extensions require extra attention.  Check for those formats, and send the PhotoDemon_SaveImage
                ' method a specialized string containing any extra information it may require
                If imageFormats.getOutputFormatExtension(cmbOutputFormat.ListIndex) = "jpg" Then
                    PhotoDemon_SaveImage CLng(FormMain.ActiveForm.Tag), tmpFilename, False, Val(txtQuality)
                Else
                    PhotoDemon_SaveImage CLng(FormMain.ActiveForm.Tag), tmpFilename
                End If
            
                'Kill the next-to-last form (better than killing the current one, because of the constant GD flickering)
                If (curBatchFile > 0) Or (curPage > 0) Then Unload pdImages(CurrentImage - 1).containingForm
            
            Next curPage
            
            'If a good number of images have been processed, we can start to estimate the amount of time remaining
            If (curBatchFile > 40) Then
                timeElapsed = GetTickCount - timeStarted
                numFilesProcessed = curBatchFile + 1
                numFilesRemaining = totalNumOfFiles - numFilesProcessed
                timePerFile = timeElapsed / numFilesProcessed
                timeRemaining = timePerFile * numFilesRemaining
                
                'Convert timeRemaining to seconds (its currently in milliseconds
                timeRemaining = timeRemaining / 1000
                
                minutesRemaining = Int(timeRemaining / 60)
                secondsRemaining = Int(timeRemaining) Mod 60
                
                'This lets us format our time nicely (e.g. "minute" vs "minutes")
                Select Case minutesRemaining
                    'No minutes remaining - only seconds
                    Case 0
                        timeMsg = ".  Estimated time remaining: "
                    Case 1
                        timeMsg = ".  Estimated time remaining: " & minutesRemaining & " minute "
                    Case Else
                        timeMsg = ".  Estimated time remaining: " & minutesRemaining & " minutes "
                End Select
                
                Select Case secondsRemaining
                    Case 1
                        timeMsg = timeMsg & "1 second"
                    Case Else
                        timeMsg = timeMsg & secondsRemaining & " seconds"
                End Select

            ElseIf (curBatchFile > 20) And (totalNumOfFiles > 50) Then
                timeMsg = ".  Estimating time remaining..."
            End If
        
        End If
        
    'Carry on
    Next curBatchFile
    
    'Unload the last form we processed
    If Not FormMain.ActiveForm Is Nothing Then Unload FormMain.ActiveForm
    
    MacroStatus = MacroSTOP
    
    Screen.MousePointer = vbDefault
    
    'Now we can use the traditional progress bar and message calls
    SetProgBarVal 0
    Message "Batch conversion of " & totalNumOfFiles & " files was successful!"
    
    Unload Me
    
    Exit Sub
    
MacroCanceled:

    MacroStatus = MacroSTOP
    
    Screen.MousePointer = vbDefault
    
    SetProgBarVal 0
    
    Dim cancelMsg As String
    
    cancelMsg = "Batch conversion canceled. " & curBatchFile & " image"
    
    'Properly display "image" or "images" depending on how many files were processed
    If curBatchFile <> 1 Then cancelMsg = cancelMsg & "s were " Else cancelMsg = cancelMsg & " was "
    
    cancelMsg = cancelMsg & "processed before cancelation. Last processed image was """ & lstFiles.List(curBatchFile) & """."
    
    Message cancelMsg
    
    Unload Me
    
End Sub

'Use "shell32.dll" to select a folder
Private Sub cmdSelectOutputPath_Click()
    Dim tString As String
    tString = BrowseForFolder(FormBatchConvert.hWnd)
    If tString <> "" Then
        txtOutputPath.Text = FixPath(tString)
    
        'Save this new directory as the default path for future usage
        userPreferences.SetPreference_String "Batch Preferences", "OutputFolder", tString
    End If
End Sub

'Use the common dialog interface to select an image file for processing
Private Sub cmdUseCD_Click()
    
    'String returned from the common dialog wrapper
    Dim sFile() As String
    
    If PhotoDemon_OpenImageDialog(sFile, Me.hWnd) Then
        
        For x = 0 To UBound(sFile)
            lstFiles.AddItem sFile(x)
        Next x
        
    End If

End Sub

'When the drive and directory boxes are changed, update the connected boxes to match
Private Sub Dir1_Change()
    File1.Path = Dir1
End Sub

Private Sub Drive1_Change()
    Dir1.Path = Drive1
    File1.Path = Dir1
End Sub

'Initialize various controls and options
Private Sub Form_Load()

    'Start without a macro file loaded
    LocationOfMacroFile = "N/A"
    
    Dim x As Long
    
    'Populate the combo box that displays user-friendly summaries of the various output filetypes
    For x = 0 To imageFormats.getNumOfOutputFormats
        cmbOutputFormat.AddItem imageFormats.getOutputFormatDescription(x), x
    Next x
    
    'Save JPEGs by default
    For x = 0 To cmbOutputFormat.ListCount
        If imageFormats.getOutputFormatExtension(x) = "jpg" Then
            cmbOutputFormat.ListIndex = x
            jpegFormatIndex = x
            Exit For
        End If
    Next x
    
    'Build default paths from INI file values
    Dim tempPathString As String
    tempPathString = userPreferences.GetPreference_String("Batch Preferences", "DriveBox", "")
    If (tempPathString <> "") And (DirectoryExist(tempPathString)) Then Drive1 = tempPathString
    tempPathString = userPreferences.GetPreference_String("Batch Preferences", "InputFolder", "")
    If (tempPathString <> "") And (DirectoryExist(tempPathString)) Then Dir1.Path = tempPathString Else Dir1.Path = Drive1
    File1.Path = Dir1
    tempPathString = userPreferences.GetPreference_String("Batch Preferences", "OutputFolder", "")
    If (tempPathString <> "") And (DirectoryExist(tempPathString)) Then txtOutputPath.Text = tempPathString Else txtOutputPath.Text = Dir1
    
    'Options for output filenames
    cmbOutputOptions.AddItem "Original filenames"
    cmbOutputOptions.AddItem "Ascending numbers (1, 2, 3, etc.)"
    cmbOutputOptions.ListIndex = 0
    
    'Populate the combo box that displays user-friendly summaries of the various input filetypes
    For x = 0 To imageFormats.getNumOfInputFormats
        cmbPattern.AddItem imageFormats.getInputFormatDescription(x), x
    Next x
        
    cmbPattern.ListIndex = 0
    
    'Assign the system hand cursor to all relevant objects
    makeFormPretty Me
    
End Sub

'Enable/disable the macro selection box and command button contingent on which macro option button is selected
Private Sub optActions_Click(Index As Integer)
    If optActions(0).Value = True Then
        cmdSelectMacro.Enabled = False
        txtMacro.Enabled = False
    Else
        cmdSelectMacro.Enabled = True
        txtMacro.Enabled = True
    End If
End Sub

Private Sub optActions_KeyUp(Index As Integer, KeyCode As Integer, Shift As Integer)
    If optActions(0).Value = True Then
        cmdSelectMacro.Enabled = False
        txtMacro.Enabled = False
    Else
        cmdSelectMacro.Enabled = True
        txtMacro.Enabled = True
    End If
End Sub

Private Sub txtAppendFront_GotFocus()
    AutoSelectText txtAppendFront
End Sub

Private Sub txtAppendFront_LostFocus()
    'Make sure the text the user wants to append to filenames doesn't lead to invalid filename errors
    Dim tmpString As String
    tmpString = txtAppendFront
    makeValidWindowsFilename tmpString
    txtAppendFront = tmpString
End Sub

Private Sub txtMacro_GotFocus()
    AutoSelectText txtMacro
End Sub

Private Sub txtOutputPath_GotFocus()
    AutoSelectText txtOutputPath
End Sub

'*****
'The following set of routines is for the JPEG textbox, label, and slider control
Private Sub hsJpegQuality_Change()
    txtQuality.Text = hsJpegQuality.Value
End Sub

Private Sub hsJpegQuality_Scroll()
    txtQuality.Text = hsJpegQuality.Value
End Sub

Private Sub txtQuality_Change()
    If EntryValid(txtQuality, hsJpegQuality.Min, hsJpegQuality.Max, False, False) Then hsJpegQuality.Value = Val(txtQuality)
End Sub

Private Sub txtQuality_GotFocus()
    AutoSelectText txtQuality
End Sub
'*****

'Display or hide controls associated with the current save file format
Private Sub UpdateVisibleControls()
    If imageFormats.getOutputFormatExtension(cmbOutputFormat.ListIndex) = "jpg" Then
        lblQuality.Visible = True
        txtQuality.Visible = True
        hsJpegQuality.Visible = True
    Else
        lblQuality.Visible = False
        txtQuality.Visible = False
        hsJpegQuality.Visible = False
    End If
End Sub
