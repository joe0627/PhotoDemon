Attribute VB_Name = "Processor"
'***************************************************************************
'Program Sub-Processor and Error Handler
'Copyright �2000-2012 by Tanner Helland
'Created: 4/15/01
'Last updated: 13/August/12
'Last update: built GetNameOfProcess for returning human-readable descriptions of processes
'
'Module for controlling calls to the various program functions.  Any action the program takes has to pass
' through here.  Why go to all that extra work?  A couple of reasons:
' 1) a central error handler that works for every sub throughout the program (due to recursive error handling)
' 2) PhotoDemon can run macros by simply tracking the values that pass through this routine
' 3) PhotoDemon can control code flow by delaying requests that pass through here (for example,
'    if the program is busy applying a filter, we can wait to process subsequent calls)
' 4) miscellaneous semantic benefits
'
'Due to the nature of this routine, very little of interest happens here - this is primarily a router
' for various functions, so the majority of the routine is a huge Case Select statement.
'
'***************************************************************************

Option Explicit

'GROUP IDENTIFIERS: Specify the broader group that an option is within
    '...may be added later, depending on preview options (such as if an effect browser is
    'created...)
'END GROUP IDENTIFIERS

'SUBIDENTIFIERS: Specify specific actions within a group

    'Main functions (not used for image editing); numbers 1-99
    '-File I/O
    Public Const FileOpen As Long = 1
    Public Const FileSave As Long = 2
    Public Const FileSaveAs As Long = 3
    '-Screen Capture
    Public Const capScreen As Long = 10
    'Clipboard constants:
    Public Const cCopy As Long = 20
    Public Const cPaste As Long = 21
    Public Const cEmpty As Long = 22
    'Undo
    Public Const Undo As Long = 30
    Public Const Redo As Long = 31
    'Macro conversion
    Public Const MacroStartRecording As Long = 40
    Public Const MacroStopRecording As Long = 41
    Public Const MacroPlayRecording As Long = 42
    'Scanning
    Public Const SelectScanner As Long = 50
    Public Const ScanImage As Long = 51
    
    'Histogram functions; numbers 100-199
    Public Const ViewHistogram As Long = 100
    Public Const StretchHistogram As Long = 101
    Public Const Equalize As Long = 102
    Public Const WhiteBalance As Long = 104
    'Note: 103 is empty (formerly EqualizeLuminance, which is now handled as part of Equalize)
    
    'Black/White conversion; numbers 200-299
    Public Const BWImpressionist As Long = 200
    Public Const BWNearestColor As Long = 201
    Public Const BWComponent As Long = 202
    Public Const BWOrderedDither As Long = 203
    Public Const BWDiffusionDither As Long = 204
    Public Const Threshold As Long = 205
    Public Const ComicBook As Long = 206
    Public Const BWEnhancedDither As Long = 207
    Public Const BWFloydSteinberg As Long = 208
    Public Const BWMaster As Long = 210 'Added 9/2012 - this is a single BW conversion routine to rule them all
    
    'Grayscale conversion; numbers 300-399
    Public Const Desaturate As Long = 300
    Public Const GrayScale As Long = 301
    Public Const GrayscaleAverage As Long = 302
    Public Const GrayscaleCustom As Long = 303
    Public Const GrayscaleCustomDither As Long = 304
    Public Const GrayscaleDecompose As Long = 305
    Public Const GrayscaleSingleChannel As Long = 306
    
    'Area filters; numbers 400-499
    '-Blur
    Public Const Blur As Long = 400
    Public Const BlurMore As Long = 401
    Public Const Soften As Long = 402
    Public Const SoftenMore As Long = 403
    '-Sharpen
    Public Const Sharpen As Long = 404
    Public Const SharpenMore As Long = 405
    Public Const Unsharp As Long = 406
    '-Diffuse
    Public Const Diffuse As Long = 407
    Public Const DiffuseMore As Long = 408
    Public Const CustomDiffuse As Long = 409
    '-Mosaic
    Public Const Mosaic As Long = 410
    '-Rank
    '411-413 have been moved into the CustomRank function.
    Public Const CustomRank As Long = 414
    '-Grid Blurring
    Public Const GridBlur As Long = 415
    '-Gaussian Blur
    Public Const GaussianBlur As Long = 416
    Public Const GaussianBlurMore As Long = 417
    '-Antialias
    Public Const Antialias As Long = 418
    
    'Edge filters; numbers 500-599
    '-Emboss
    Public Const EmbossToColor As Long = 500
    '-Engrave
    Public Const EngraveToColor As Long = 501
    '-Pencil
    Public Const Pencil As Long = 504
    '-Relief
    Public Const Relief As Long = 505
    '-Find Edges
    Public Const PrewittHorizontal As Long = 506
    Public Const PrewittVertical As Long = 507
    Public Const SobelHorizontal As Long = 508
    Public Const SobelVertical As Long = 509
    Public Const Laplacian As Long = 510
    Public Const SmoothContour As Long = 511
    Public Const HiliteEdge As Long = 512
    Public Const PhotoDemonEdgeLinear = 513
    Public Const PhotoDemonEdgeCubic = 514
    '-Edge enhance
    Public Const EdgeEnhance As Long = 515
    
    'Color operations; numbers 600-699
    '-Rechanneling
    Public Const Rechannel As Long = 600
    Public Const RechannelGreen As Long = 601   'This is here for legacy reasons only
    Public Const RechannelRed As Long = 602     'This is here for legacy reasons only
    '-Shifting
    Public Const ColorShiftLeft As Long = 603
    Public Const ColorShiftRight As Long = 604
    '-Intensity
    Public Const BrightnessAndContrast As Long = 605
    Public Const GammaCorrection As Long = 606
    '-Invert/Negative
    Public Const Invert As Long = 607
    Public Const InvertHue As Long = 608
    Public Const Negative As Long = 609
    Public Const CompoundInvert As Long = 617
    '-AutoEnhance
    Public Const AutoEnhance As Long = 610
    Public Const AutoHighlights As Long = 611
    Public Const AutoMidtones As Long = 612
    Public Const AutoShadows As Long = 613
    'Image levels
    Public Const ImageLevels As Long = 614
    'Colorize
    Public Const Colorize As Long = 615
    'Reduce image colors
    Public Const ReduceColors As Long = 616
    'Temperature
    Public Const AdjustTemperature As Long = 618
    'HSL Adjustment
    Public Const AdjustHSL As Long = 619
    'NOTE: 619 is the max value for this section (AdjustHSL)
    
    'Coordinate filters/transformations; numbers 700-799
    '-Resize
    Public Const ImageSize As Long = 700
    '-Orientation
    Public Const Flip As Long = 701
    Public Const Mirror As Long = 702
    '-Rotation
    Public Const Rotate90Clockwise As Long = 703
    Public Const Rotate180 As Long = 704
    Public Const Rotate270Clockwise As Long = 705
    Public Const FreeRotate As Long = 706
    '-Isometric
    Public Const Isometric As Long = 707
    '-Tiling
    Public Const Tile As Long = 708
    '-Crop to Selection
    Public Const CropToSelection As Long = 709
    '-Image Mode (it's a kind of transformation, right?)
    Public Const ChangeImageMode24 As Long = 710
    Public Const ChangeImageMode32 As Long = 711
    
    'Other filters; numbers 800-899
    '-Compound invert
    '800-802 used to be specific CompoundInvert values; this is superceded by passing the values to CompoundInvert, which has been moved with the other Inverts
    '-Fade
    Public Const Fade As Long = 803
    '804-806 used to be specific Fade values; these have been superceded by passing the values to Fade
    Public Const Unfade As Long = 807
    '-Natural
    Public Const Atmospheric As Long = 808
    Public Const Frozen As Long = 809
    Public Const Lava As Long = 810
    Public Const Burn As Long = 811
    Public Const Ocean As Long = 812
    Public Const Water As Long = 813
    Public Const Steel As Long = 814
    Public Const FogEffect As Long = 828
    Public Const Rainbow As Long = 829
    '-Custom filters
    Public Const CustomFilter As Long = 817
    '-Miscellaneous
    Public Const Dream As Long = 815
    Public Const Alien As Long = 816
    Public Const Antique As Long = 818
    Public Const BlackLight As Long = 819
    Public Const Posterize As Long = 820
    Public Const Radioactive As Long = 821
    Public Const Solarize As Long = 822
    Public Const Twins As Long = 823
    Public Const Synthesize As Long = 824
    Public Const Noise As Long = 825
    Public Const Sepia As Long = 826
    Public Const CountColors As Long = 827
    Public Const Vibrate As Long = 830
    Public Const Despeckle As Long = 831
    Public Const CustomDespeckle As Long = 832
    Public Const HeatMap As Long = 833
    Public Const Animate As Long = 840
    
    'Relative processes
    Public Const LastCommand As Long = 900
    Public Const FadeLastEffect As Long = 901
    
    'Other filters end at 840

    'On-Canvas Tools; numbers 1000-2000
    
    'Selections
    Public Const SelectionCreate As Long = 1000
    Public Const SelectionClear As Long = 1001
    
    'Reserved bytes; 2000 and up
    
'END SUBIDENTIFIERS (~130? currently)

'Data type for tracking processor calls - used for macros
'2012 model: MOST CURRENT
Public Type ProcessCall
    MainType As Long
    pOPCODE As Variant
    pOPCODE2 As Variant
    pOPCODE3 As Variant
    pOPCODE4 As Variant
    pOPCODE5 As Variant
    pOPCODE6 As Variant
    pOPCODE7 As Variant
    pOPCODE8 As Variant
    pOPCODE9 As Variant
    LoadForm As Boolean
    RecordAction As Boolean
End Type

'Array of processor calls - tracks what is going on
Public Calls() As ProcessCall

'Tracks the current array position
Public CurrentCall As Long

'Last filter call
Public LastFilterCall As ProcessCall

'Track processing (i.e. whether or not the software processor is busy right now
Public Processing As Boolean

'PhotoDemon's software processor.  Almost every action the program takes is routed through this method.  This is what
' allows us to record and playback macros, among other things.  (See comment at top of page for more details.)
Public Sub Process(ByVal pType As Long, Optional pOPCODE As Variant = 0, Optional pOPCODE2 As Variant = 0, Optional pOPCODE3 As Variant = 0, Optional pOPCODE4 As Variant = 0, Optional pOPCODE5 As Variant = 0, Optional pOPCODE6 As Variant = 0, Optional pOPCODE7 As Variant = 0, Optional pOPCODE8 As Variant = 0, Optional pOPCODE9 As Variant = 0, Optional LoadForm As Boolean = False, Optional RecordAction As Boolean = True)

    'Main error handler for the entire program is initialized by this line
    On Error GoTo MainErrHandler
    
    'If desired, this line can be used to artificially raise errors (to test the error handler)
    'Err.Raise 339
    
    'Mark the software processor as busy
    Processing = True
        
    'Set the mouse cursor to an hourglass and lock the main form (to prevent additional input)
    If LoadForm = False Then
        Screen.MousePointer = vbHourglass
    Else
        setArrowCursor FormMain.ActiveForm
    End If
    
    FormMain.Enabled = False
        
    'If we are to perform the last command, simply replace all the method parameters using data from the
    ' LastFilterCall object, then let the routine carry on as usual
    If pType = LastCommand Then
        pType = LastFilterCall.MainType
        pOPCODE = LastFilterCall.pOPCODE
        pOPCODE2 = LastFilterCall.pOPCODE2
        pOPCODE3 = LastFilterCall.pOPCODE3
        pOPCODE4 = LastFilterCall.pOPCODE4
        pOPCODE5 = LastFilterCall.pOPCODE5
        pOPCODE6 = LastFilterCall.pOPCODE6
        pOPCODE7 = LastFilterCall.pOPCODE7
        pOPCODE8 = LastFilterCall.pOPCODE8
        pOPCODE9 = LastFilterCall.pOPCODE9
        LoadForm = LastFilterCall.LoadForm
    End If
    
    'If the macro recorder is running and this option is recordable, store it in our array of
    'processor calls
    If (MacroStatus = MacroSTART) And (RecordAction = True) Then
        'Tracker variable (remembers where we are at in the array)
        CurrentCall = CurrentCall + 1
        
        'Copy the current function variables into the array
        ReDim Preserve Calls(0 To CurrentCall) As ProcessCall
        With Calls(CurrentCall)
            .MainType = pType
            .pOPCODE = pOPCODE
            .pOPCODE2 = pOPCODE2
            .pOPCODE3 = pOPCODE3
            .pOPCODE4 = pOPCODE4
            .pOPCODE5 = pOPCODE5
            .pOPCODE6 = pOPCODE6
            .pOPCODE7 = pOPCODE7
            .pOPCODE8 = pOPCODE8
            .pOPCODE9 = pOPCODE9
            .LoadForm = LoadForm
            .RecordAction = RecordAction
        End With
    End If
    
    
    'SUB HANDLER/PROCESSOR
    'From this point on, all we do is check the pType variable (the first variable passed
    ' to this subroutine) and depending on what it is, we call the appropriate subroutine.
    ' Very simple and very fast.
    
    'I have also subdivided the "Select Case" statements into groups of 100, just as I do
    ' above in the declarations part.  This is purely organizational.
    
    'Process types 0-99.  Main functions.  These are never recorded as part of macros.
    If pType > 0 And pType <= 99 Then
        Select Case pType
            Case FileOpen
                MenuOpen
            Case FileSave
                MenuSave CurrentImage
            Case FileSaveAs
                MenuSaveAs CurrentImage
            Case capScreen
                CaptureScreen
            Case cCopy
                ClipboardCopy
            Case cPaste
                ClipboardPaste
            Case cEmpty
                ClipboardEmpty
            Case Undo
                RestoreImage
                'Also, redraw the current child form icon
                CreateCustomFormIcon FormMain.ActiveForm
            Case Redo
                RedoImageRestore
                'Also, redraw the current child form icon
                CreateCustomFormIcon FormMain.ActiveForm
            Case MacroStartRecording
                StartMacro
            Case MacroStopRecording
                StopMacro
            Case MacroPlayRecording
                PlayMacro
            Case SelectScanner
                Twain32SelectScanner
            Case ScanImage
                Twain32Scan
        End Select
    End If
    
    'NON-IDENTIFIER CODE
    'Get image data and build the undo for any action that changes the image buffer
    
    'First, make sure that the current command is a filter or image-changing event
    If pType >= 101 Then
        
        'Only save an "undo" image if we are NOT loading a form for user input, and if
        'we ARE allowed to record this action, and if it's not counting colors (useless),
        ' and if we're not performing a batch conversion (saves a lot of time to not generate undo files!)
        If MacroStatus <> MacroBATCH Then
            If LoadForm <> True And RecordAction <> False And pType <> CountColors Then CreateUndoFile pType
        End If
        
        'Save this information in the LastFilterCall variable (to be used if the user clicks on
        ' Edit -> Redo Last Command.
        FormMain.MnuRepeatLast.Enabled = True
        LastFilterCall.MainType = pType
        LastFilterCall.pOPCODE = pOPCODE
        LastFilterCall.pOPCODE2 = pOPCODE2
        LastFilterCall.pOPCODE3 = pOPCODE3
        LastFilterCall.pOPCODE4 = pOPCODE4
        LastFilterCall.pOPCODE5 = pOPCODE5
        LastFilterCall.pOPCODE6 = pOPCODE6
        LastFilterCall.pOPCODE7 = pOPCODE7
        LastFilterCall.pOPCODE8 = pOPCODE8
        LastFilterCall.pOPCODE9 = pOPCODE9
        LastFilterCall.LoadForm = LoadForm
        
    End If
    
    'Histogram functions
    If pType >= 100 And pType <= 199 Then
        Select Case pType
            Case ViewHistogram
                FormHistogram.Show 0
            Case StretchHistogram
                FormHistogram.StretchHistogram
            Case Equalize
                If LoadForm = True Then
                    FormEqualize.Show 1, FormMain
                Else
                    FormEqualize.EqualizeHistogram pOPCODE, pOPCODE2, pOPCODE3, pOPCODE4
                End If
            Case WhiteBalance
                If LoadForm = True Then
                    FormWhiteBalance.Show 1, FormMain
                Else
                    FormWhiteBalance.AutoWhiteBalance pOPCODE
                End If
        End Select
    End If
    
    'Black/White conversion
    'NOTE: as of PhotoDemon v5.0 all black/white conversions are being rebuilt in a single master function (masterBlackWhiteConversion).
    ' For sake of compatibility with old macros, I need to make sure old processor values are rerouted through the new master function.
    If pType >= 200 And pType <= 299 Then
        Select Case pType
            Case BWImpressionist
                If LoadForm = True Then
                    FormBlackAndWhite.Show 1, FormMain
                Else
                    'MenuBWImpressionist
                End If
            Case BWNearestColor
                'MenuBWNearestColor
            Case BWComponent
                'MenuBWComponent
            Case BWOrderedDither
                'MenuBWOrderedDither
            Case BWDiffusionDither
                'MenuBWDiffusionDither
            Case Threshold
                'MenuThreshold pOPCODE
            Case ComicBook
                MenuComicBook
            Case BWEnhancedDither
                'MenuBWEnhancedDither
            Case BWFloydSteinberg
                'MenuBWFloydSteinberg
            Case BWMaster
                FormBlackAndWhite.masterBlackWhiteConversion pOPCODE, pOPCODE2, pOPCODE3, pOPCODE4
        End Select
    End If
    
    'Grayscale conversion
    If pType >= 300 And pType <= 399 Then
        Select Case pType
            Case Desaturate
                FormGrayscale.MenuDesaturate
            Case GrayScale
                If LoadForm = True Then
                    FormGrayscale.Show 1, FormMain
                Else
                    FormGrayscale.MenuGrayscale
                End If
            Case GrayscaleAverage
                FormGrayscale.MenuGrayscaleAverage
            Case GrayscaleCustom
                FormGrayscale.fGrayscaleCustom pOPCODE
            Case GrayscaleCustomDither
                FormGrayscale.fGrayscaleCustomDither pOPCODE
            Case GrayscaleDecompose
                FormGrayscale.MenuDecompose pOPCODE
            Case GrayscaleSingleChannel
                FormGrayscale.MenuGrayscaleSingleChannel pOPCODE
        End Select
    End If
    
    'Area filters
    If pType >= 400 And pType <= 499 Then
        Select Case pType
            Case Blur
                FilterBlur
            Case BlurMore
                FilterBlurMore
            Case Soften
                FilterSoften
            Case SoftenMore
                FilterSoftenMore
            Case Sharpen
                FilterSharpen
            Case SharpenMore
                FilterSharpenMore
            Case Unsharp
                FilterUnsharp
            Case Diffuse
                FormDiffuse.Diffuse
            Case DiffuseMore
                FormDiffuse.DiffuseMore
            Case CustomDiffuse
                If LoadForm = True Then
                    FormDiffuse.Show 1, FormMain
                Else
                    FormDiffuse.DiffuseCustom pOPCODE, pOPCODE2, pOPCODE3
                End If
            Case Mosaic
                If LoadForm = True Then
                    FormMosaic.Show 1, FormMain
                Else
                    FormMosaic.MosaicFilter CInt(pOPCODE), CInt(pOPCODE2)
                End If
            Case CustomRank
                If LoadForm = True Then
                    FormRank.Show 1, FormMain
                Else
                    FormRank.CustomRankFilter CInt(pOPCODE), CByte(pOPCODE2)
                End If
            Case GridBlur
                FilterGridBlur
            Case Antialias
                FilterAntialias
            Case GaussianBlur
                FilterGaussianBlur
            Case GaussianBlurMore
                FilterGaussianBlurMore
        End Select
    End If
    
    'Edge filters
    If pType >= 500 And pType <= 599 Then
        Select Case pType
            Case EmbossToColor
                If LoadForm = True Then
                    FormEmbossEngrave.Show 1, FormMain
                Else
                    FormEmbossEngrave.FilterEmbossColor CLng(pOPCODE)
                End If
            Case EngraveToColor
                FormEmbossEngrave.FilterEngraveColor CLng(pOPCODE)
            Case Pencil
                FilterPencil
            Case Relief
                FilterRelief
            Case SmoothContour
                FormFindEdges.FilterSmoothContour pOPCODE
            Case PrewittHorizontal
                FormFindEdges.FilterPrewittHorizontal pOPCODE
            Case PrewittVertical
                FormFindEdges.FilterPrewittVertical pOPCODE
            Case SobelHorizontal
               FormFindEdges.FilterSobelHorizontal pOPCODE
            Case SobelVertical
                FormFindEdges.FilterSobelVertical pOPCODE
            Case Laplacian
                If LoadForm = True Then
                    FormFindEdges.Show 1, FormMain
                Else
                    FormFindEdges.FilterLaplacian pOPCODE
                End If
            Case HiliteEdge
                FormFindEdges.FilterHilite pOPCODE
            Case PhotoDemonEdgeLinear
                FormFindEdges.PhotoDemonLinearEdgeDetection pOPCODE
            Case PhotoDemonEdgeCubic
                FormFindEdges.PhotoDemonCubicEdgeDetection pOPCODE
            Case EdgeEnhance
                FilterEdgeEnhance
        End Select
    End If
    
    'Color operations
    If pType >= 600 And pType <= 699 Then
        Select Case pType
            Case Rechannel
                If LoadForm = True Then
                    FormRechannel.Show 1, FormMain
                Else
                    FormRechannel.RechannelImage CLng(pOPCODE)
                End If
            'RechannelGreen and RechannelRed are only included for legacy reasons
            Case RechannelGreen
                FormRechannel.RechannelImage pOPCODE
            Case RechannelRed
                FormRechannel.RechannelImage pOPCODE
            '------
            Case ColorShiftLeft
                MenuCShift pOPCODE
            Case ColorShiftRight
                MenuCShift pOPCODE
            Case BrightnessAndContrast
                If LoadForm = True Then
                    FormBrightnessContrast.Show 1, FormMain
                Else
                    FormBrightnessContrast.BrightnessContrast CInt(pOPCODE), CSng(pOPCODE2), CBool(pOPCODE3)
                End If
            Case GammaCorrection
                If LoadForm = True Then
                    FormGamma.Show 1, FormMain
                Else
                    FormGamma.GammaCorrect CSng(pOPCODE), CByte(pOPCODE2)
                End If
            Case Invert
                MenuInvert
            Case CompoundInvert
                MenuCompoundInvert CLng(pOPCODE)
            Case Negative
                MenuNegative
            Case InvertHue
                MenuInvertHue
            Case AutoEnhance
                MenuAutoEnhanceContrast
            Case AutoHighlights
                MenuAutoEnhanceHighlights
            Case AutoMidtones
                MenuAutoEnhanceMidtones
            Case AutoShadows
                MenuAutoEnhanceShadows
            Case ImageLevels
                If LoadForm = True Then
                    FormLevels.Show 1, FormMain
                Else
                    FormLevels.MapImageLevels pOPCODE, pOPCODE2, pOPCODE3, pOPCODE4, pOPCODE5
                End If
            Case Colorize
                If LoadForm = True Then
                    FormColorize.Show 1, FormMain
                Else
                    FormColorize.ColorizeImage pOPCODE, pOPCODE2
                End If
            Case ReduceColors
                If LoadForm = True Then
                    FormReduceColors.Show 1, FormMain
                Else
                    If pOPCODE = REDUCECOLORS_AUTO Then
                        FormReduceColors.ReduceImageColors_Auto pOPCODE2
                    ElseIf pOPCODE = REDUCECOLORS_MANUAL Then
                        FormReduceColors.ReduceImageColors_BitRGB pOPCODE2, pOPCODE3, pOPCODE4, pOPCODE5
                    ElseIf pOPCODE = REDUCECOLORS_MANUAL_ERRORDIFFUSION Then
                        FormReduceColors.ReduceImageColors_BitRGB_ErrorDif pOPCODE2, pOPCODE3, pOPCODE4, pOPCODE5
                    Else
                        MsgBox "Unsupported color reduction method."
                    End If
                End If
            Case AdjustTemperature
                If LoadForm = True Then
                    FormColorTemp.Show 1, FormMain
                Else
                    FormColorTemp.ApplyTemperatureToImage pOPCODE, pOPCODE2, pOPCODE3
                End If
            Case AdjustHSL
                If LoadForm = True Then
                    FormHSL.Show 1, FormMain
                Else
                    FormHSL.AdjustImageHSL pOPCODE, pOPCODE2, pOPCODE3
                End If
        End Select
    End If
    
    'Coordinate filters/transformations
    If pType >= 700 And pType <= 799 Then
        Select Case pType
            Case Flip
                MenuFlip
            Case FreeRotate
                If LoadForm = True Then
                    FormRotate.Show 1, FormMain
                Else
                    FormRotate.RotateArbitrary pOPCODE, pOPCODE2
                End If
            Case Mirror
                MenuMirror
            Case Rotate90Clockwise
                MenuRotate90Clockwise
            Case Rotate180
                MenuRotate180
            Case Rotate270Clockwise
                MenuRotate270Clockwise
            Case Isometric
                FilterIsometric
            Case ImageSize
                If LoadForm = True Then
                    FormResize.Show 1, FormMain
                Else
                    FormResize.ResizeImage CLng(pOPCODE), CLng(pOPCODE2), CByte(pOPCODE3)
                End If
            Case Tile
                If LoadForm = True Then
                    FormTile.Show 1, FormMain
                Else
                    FormTile.GenerateTile CByte(pOPCODE), CLng(pOPCODE2), CLng(pOPCODE3)
                End If
            Case CropToSelection
                MenuCropToSelection
            Case ChangeImageMode24
                ConvertImageColorDepth 24
            Case ChangeImageMode32
                ConvertImageColorDepth 32
        End Select
    End If
    
    'Other filters
    If pType >= 800 And pType <= 899 Then
        Select Case pType
            Case Antique
                MenuAntique
            Case Atmospheric
                MenuAtmospheric
            Case BlackLight
                If LoadForm = True Then
                    FormBlackLight.Show 1, FormMain
                Else
                    FormBlackLight.fxBlackLight pOPCODE
                End If
            Case Dream
                MenuDream
            Case Posterize
                If LoadForm = True Then
                    FormPosterize.Show 1, FormMain
                Else
                    FormPosterize.PosterizeImage CByte(pOPCODE)
                End If
            Case Radioactive
                MenuRadioactive
            Case Solarize
                If LoadForm = True Then
                    FormSolarize.Show 1, FormMain
                Else
                    FormSolarize.SolarizeImage CByte(pOPCODE)
                End If
            Case Twins
                If LoadForm = True Then
                    FormTwins.Show 1, FormMain
                Else
                    FormTwins.GenerateTwins CByte(pOPCODE)
                End If
            Case Fade
                If LoadForm = True Then
                    FormFade.Show 1, FormMain
                Else
                    FormFade.FadeImage CSng(pOPCODE)
                End If
            Case Unfade
                FormFade.UnfadeImage
            Case Alien
                MenuAlien
            Case Synthesize
                MenuSynthesize
            Case Water
                MenuWater
            Case Noise
                If LoadForm = True Then
                    FormNoise.Show 1, FormMain
                Else
                    FormNoise.AddNoise CInt(pOPCODE), CByte(pOPCODE2)
                End If
            Case Frozen
                MenuFrozen
            Case Lava
                MenuLava
            Case CustomFilter
                If LoadForm = True Then
                    FormCustomFilter.Show 1, FormMain
                Else
                    DoFilter , , pOPCODE
                End If
            Case Burn
                MenuBurn
            Case Ocean
                MenuOcean
            Case Steel
                MenuSteel
            Case FogEffect
                MenuFogEffect
            Case CountColors
                MenuCountColors
            Case Rainbow
                MenuRainbow
            Case Vibrate
                MenuVibrate
            Case Despeckle
                FormDespeckle.QuickDespeckle
            Case CustomDespeckle
                If LoadForm = True Then
                    FormDespeckle.Show 1, FormMain
                Else
                    FormDespeckle.Despeckle pOPCODE
                End If
            Case Animate
                MenuAnimate
            Case Sepia
                MenuSepia
            Case HeatMap
                MenuHeatMap
        
        End Select
    End If
    
    'Finally, check to see if the user wants us to fade the last effect applied to the image...
    If pType = FadeLastEffect Then MenuFadeLastEffect
    
    'Restore the mouse pointer to its default value; if we are running a batch conversion, however, leave it busy
    ' The batch routine will handle restoring the cursor to normal.
    If MacroStatus <> MacroBATCH Then Screen.MousePointer = vbDefault
    
    'If the histogram form is visible and images are loaded, redraw the histogram
    If FormHistogram.Visible = True Then
        If NumOfWindows > 0 Then
            FormHistogram.TallyHistogramValues
            FormHistogram.DrawHistogram
        Else
            'If the histogram is visible but no images are open, unload the histogram
            Unload FormHistogram
        End If
    End If
    
    'If the image is potentially being changed and we are not performing a batch conversion (disabled to save speed!),
    ' redraw the active MDI child form icon.
    If (pType >= 101) And (MacroStatus <> MacroBATCH) And (LoadForm <> True) And (RecordAction <> False) And (pType <> CountColors) Then CreateCustomFormIcon FormMain.ActiveForm
    
    'Mark the processor as no longer busy and unlock the main form
    FormMain.Enabled = True
    
    'If a filter or tool was just used, return focus to the active form
    If (pType >= 101) And (MacroStatus <> MacroBATCH) And (LoadForm <> True) Then
        If NumOfWindows > 0 Then FormMain.ActiveForm.SetFocus
    End If
    
    Processing = False
    
    Exit Sub


'MAIN PHOTODEMON ERROR HANDLER STARTS HERE

MainErrHandler:

    'Reset the mouse pointer and access to the main form
    Screen.MousePointer = vbDefault
    FormMain.Enabled = True

    'We'll use this string to hold additional error data
    Dim AddInfo As String
    
    'This variable stores the message box type
    Dim mType As VbMsgBoxStyle
    
    'Tracks the user input from the message box
    Dim msgReturn As VbMsgBoxResult
    
    'Ignore errors that aren't actually errors
    If Err.Number = 0 Then Exit Sub
    
    'Object was unloaded before it could be shown - this is intentional, so ignore the error
    If Err.Number = 364 Then Exit Sub
        
    'Out of memory error
    If Err.Number = 480 Or Err.Number = 7 Then
        AddInfo = "There is not enough memory available to continue this operation.  Please free up system memory (RAM) by shutting down unneeded programs - especially your web browser, if it is open - then try the action again."
        Message "Out of memory.  Function cancelled."
        mType = vbExclamation + vbOKOnly + vbApplicationModal
    
    'Invalid picture error
    ElseIf Err.Number = 481 Then
        AddInfo = "Unfortunately, this image file appears to be invalid.  This can happen if a file does not contain image data, or if it contains image data in an unsupported format." & vbCrLf & vbCrLf & "- If you downloaded this image from the Internet, the download may have terminated prematurely.  Please try downloading the image again." & vbCrLf & vbCrLf & "- If this image file came from a digital camera, scanner, or other image editing program, it's possible that " & PROGRAMNAME & " simply doesn't understand this particular file format.  Please save the image in a generic format (such as bitmap or JPEG), then reload it."
        Message "Invalid image.  Image load cancelled."
        mType = vbExclamation + vbOKOnly + vbApplicationModal
    
        'Since we know about this error, there's no need to display the extended box.  Display a smaller one, then exit.
        MsgBox AddInfo, mType, "Invalid image file"
        
        'On an invalid picture load, there will be a blank form that needs to be dealt with.
        pdImages(CurrentImage).deactivateImage
        Unload FormMain.ActiveForm
        Exit Sub
    
    'File not found error
    ElseIf Err.Number = 53 Then
        AddInfo = "The specified file could not be located.  If it was located on removable media, please re-insert the proper floppy disk, CD, or portable drive.  If the file is not located on portable media, make sure that:" & vbCrLf & "1) the file hasn't been deleted, and..." & "2) the file location provided to " & PROGRAMNAME & " is correct."
        Message "File not found."
        mType = vbExclamation + vbOKOnly + vbApplicationModal
        
    'Unknown error
    Else
        AddInfo = PROGRAMNAME & " cannot locate additional information for this error.  That probably means this error is a bug, and it needs to be fixed!" & vbCrLf & vbCrLf & "Would you like to submit a bug report?  (It takes less than one minute, and it helps everyone who uses " & PROGRAMNAME & ".)"
        mType = vbCritical + vbYesNo + vbApplicationModal
        Message "Unknown error."
    End If
    
    'Create the message box to return the error information
    msgReturn = MsgBox(PROGRAMNAME & " has experienced an error.  Details on the problem include:" & vbCrLf & vbCrLf & _
    "Error number " & Err.Number & vbCrLf & _
    "Description: " & Err.Description & vbCrLf & vbCrLf & _
    AddInfo, mType, PROGRAMNAME & " Error Handler: #" & Err.Number)
    
    'If the message box return value is "Yes", the user has opted to file a bug report.
    If msgReturn = vbYes Then
    
        'GitHub requires a login for submitting Issues; check for that first
        Dim secondaryReturn As VbMsgBoxResult
    
        secondaryReturn = MsgBox("Thank you for submitting a bug report.  To make sure your bug is addressed as quickly as possible, PhotoDemon needs you to answer one more question." & vbCrLf & vbCrLf & "Do you have a GitHub account? (If you have no idea what this means, answer ""No"".)", vbQuestion + vbApplicationModal + vbYesNo, "Thanks for making " & PROGRAMNAME & " better")
    
        'If they have a GitHub account, let them submit the bug there.  Otherwise, send them to the tannerhelland.com contact form
        If secondaryReturn = vbYes Then
            'Shell a browser window with the GitHub issue report form
            OpenURL "https://github.com/tannerhelland/PhotoDemon/issues/new"
            
            'Display one final message box with additional instructions
            MsgBox "PhotoDemon has automatically opened a GitHub bug report webpage for you.  In the ""Title"" box, please enter the following error number with a short description of the problem: " & vbCrLf & Err.Number & vbCrLf & vbCrLf & "Any additional details you can provide in the large text box, including the steps that led up to this error, will help it get fixed as quickly as possible." & vbCrLf & vbCrLf & "When finished, click the ""Submit new issue"" button.  Thank you so much for your help!", vbInformation + vbApplicationModal + vbOKOnly, "GitHub bug report instructions"
            
        Else
            'Shell a browser window with the tannerhelland.com PhotoDemon contact form
            OpenURL "http://www.tannerhelland.com/photodemon-contact/"
            
            'Display one final message box with additional instructions
            MsgBox "PhotoDemon has automatically opened a bug report webpage for you.  In the ""Additional details"" box, please describe the steps that led up to this error." & vbCrLf & vbCrLf & "In the bottom box of that page, please enter the following error number: " & vbCrLf & Err.Number & vbCrLf & vbCrLf & "When finished, click the ""Submit"" button.  Thank you so much for your help!", vbInformation + vbApplicationModal + vbOKOnly, "Bug report instructions"
            
        End If
    
    End If
        
End Sub

'Return a string with a human-readable name of a given process ID.
Public Function GetNameOfProcess(ByVal processID As Long) As String

    Select Case processID
    
        'Main functions (not used for image editing); numbers 1-99
        Case FileOpen
            GetNameOfProcess = "Open"
        Case FileSave
            GetNameOfProcess = "Save"
        Case FileSaveAs
            GetNameOfProcess = "Save As"
        Case capScreen
            GetNameOfProcess = "Screen Capture"
        Case cCopy
            GetNameOfProcess = "Copy"
        Case cPaste
            GetNameOfProcess = "Paste"
        Case cEmpty
            GetNameOfProcess = "Empty Clipboard"
        Case Undo
            GetNameOfProcess = "Undo"
        Case Redo
            GetNameOfProcess = "Redo"
        Case MacroStartRecording
            GetNameOfProcess = "Start Macro Recording"
        Case MacroStopRecording
            GetNameOfProcess = "Stop Macro Recording"
        Case MacroPlayRecording
            GetNameOfProcess = "Play Macro"
        Case SelectScanner
            GetNameOfProcess = "Select Scanner or Camera"
        Case ScanImage
            GetNameOfProcess = "Scan Image"
            
        'Histogram functions; numbers 100-199
        Case ViewHistogram
            GetNameOfProcess = "Display Histogram"
        Case StretchHistogram
            GetNameOfProcess = "Stretch Histogram"
        Case Equalize
            GetNameOfProcess = "Equalize"
        Case WhiteBalance
            GetNameOfProcess = "White Balance"
            
        'Black/White conversion; numbers 200-299
        Case BWImpressionist
            GetNameOfProcess = "Black and White (Impressionist)"
        Case BWNearestColor
            GetNameOfProcess = "Black and White (Nearest Color)"
        Case BWComponent
            GetNameOfProcess = "Black and White (Component Color)"
        Case BWOrderedDither
            GetNameOfProcess = "Black and White (Ordered Dither)"
        Case BWDiffusionDither
            GetNameOfProcess = "Black and White (Diffusion Dither)"
        Case Threshold
            GetNameOfProcess = "Black and White (Threshold)"
        Case ComicBook
            GetNameOfProcess = "Comic Book"
        Case BWEnhancedDither
            GetNameOfProcess = "Black and White (Santos Enhanced)"
        Case BWFloydSteinberg
            GetNameOfProcess = "Black and White (Floyd-Steinberg)"
        Case BWMaster
            GetNameOfProcess = "Black and White conversion"
            
        'Grayscale conversion; numbers 300-399
        Case Desaturate
            GetNameOfProcess = "Desaturate"
        Case GrayScale
            GetNameOfProcess = "Grayscale (ITU Standard)"
        Case GrayscaleAverage
            GetNameOfProcess = "Grayscale (Average)"
        Case GrayscaleCustom
            GetNameOfProcess = "Grayscale (Custom # of Colors)"
        Case GrayscaleCustomDither
            GetNameOfProcess = "Grayscale (Custom Dither)"
        Case GrayscaleDecompose
            GetNameOfProcess = "Grayscale (Decomposition)"
        Case GrayscaleSingleChannel
            GetNameOfProcess = "Grayscale (Single Channel)"
        
        'Area filters; numbers 400-499
        Case Blur
            GetNameOfProcess = "Blur"
        Case BlurMore
            GetNameOfProcess = "Blur More"
        Case Soften
            GetNameOfProcess = "Soften"
        Case SoftenMore
            GetNameOfProcess = "Soften More"
        Case Sharpen
            GetNameOfProcess = "Sharpen"
        Case SharpenMore
            GetNameOfProcess = "Sharpen More"
        Case Unsharp
            GetNameOfProcess = "Unsharp"
        Case Diffuse
            GetNameOfProcess = "Diffuse"
        Case DiffuseMore
            GetNameOfProcess = "Diffuse More"
        Case CustomDiffuse
            GetNameOfProcess = "Custom Diffuse"
        Case Mosaic
            GetNameOfProcess = "Mosaic"
        Case CustomRank
            GetNameOfProcess = "Custom Rank"
        Case GridBlur
            GetNameOfProcess = "Grid Blur"
        Case GaussianBlur
            GetNameOfProcess = "Gaussian Blur"
        Case GaussianBlurMore
            GetNameOfProcess = "Gaussian Blur More"
        Case Antialias
            GetNameOfProcess = "Antialias"
    
        'Edge filters; numbers 500-599
        Case EmbossToColor
            GetNameOfProcess = "Emboss"
        Case EngraveToColor
            GetNameOfProcess = "Engrave"
        Case Pencil
            GetNameOfProcess = "Pencil Drawing"
        Case Relief
            GetNameOfProcess = "Relief"
        Case PrewittHorizontal
            GetNameOfProcess = "Find Edges (Prewitt Horizontal)"
        Case PrewittVertical
            GetNameOfProcess = "Find Edges (Prewitt Vertical)"
        Case SobelHorizontal
            GetNameOfProcess = "Find Edges (Sobel Horizontal)"
        Case SobelVertical
            GetNameOfProcess = "Find Edges (Sobel Vertical)"
        Case Laplacian
            GetNameOfProcess = "Find Edges (Laplacian)"
        Case SmoothContour
            GetNameOfProcess = "Artistic Contour"
        Case HiliteEdge
            GetNameOfProcess = "Find Edges (Hilite)"
        Case PhotoDemonEdgeLinear
            GetNameOfProcess = "Find Edges (PhotoDemon Linear)"
        Case PhotoDemonEdgeCubic
            GetNameOfProcess = "Find Edges (PhotoDemon Cubic)"
        Case EdgeEnhance
            GetNameOfProcess = "Edge Enhance"
            
        'Color operations; numbers 600-699
        Case Rechannel
            GetNameOfProcess = "Rechannel"
        'Rechannel Green and Red are only included for legacy reasons
        Case RechannelGreen
            GetNameOfProcess = "Rechannel (Green)"
        Case RechannelRed
            GetNameOfProcess = "Rechannel (Red)"
        '-------
        Case ColorShiftLeft
            GetNameOfProcess = "Shift Colors (Left)"
        Case ColorShiftRight
            GetNameOfProcess = "Shift Colors (Right)"
        Case BrightnessAndContrast
            GetNameOfProcess = "Brightness/Contrast"
        Case GammaCorrection
            GetNameOfProcess = "Gamma Correction"
        Case Invert
            GetNameOfProcess = "Invert Colors"
        Case InvertHue
            GetNameOfProcess = "Invert Hue"
        Case Negative
            GetNameOfProcess = "Film Negative"
        Case CompoundInvert
            GetNameOfProcess = "Compound Invert"
        Case AutoEnhance
            GetNameOfProcess = "Auto-Enhance Contrast"
        Case AutoHighlights
            GetNameOfProcess = "Auto-Enhance Highlights"
        Case AutoMidtones
            GetNameOfProcess = "Auto-Enhance Midtones"
        Case AutoShadows
            GetNameOfProcess = "Auto-Enhance Shadows"
        Case ImageLevels
            GetNameOfProcess = "Image Levels"
        Case Colorize
            GetNameOfProcess = "Colorize"
        Case ReduceColors
            GetNameOfProcess = "Reduce Colors"
        Case AdjustTemperature
            GetNameOfProcess = "Adjust Temperature"
        Case AdjustHSL
            GetNameOfProcess = "Adjust Hue/Saturation/Lightness"
            
        'Coordinate filters/transformations; numbers 700-799
        Case ImageSize
            GetNameOfProcess = "Resize"
        Case Flip
            GetNameOfProcess = "Flip"
        Case Mirror
            GetNameOfProcess = "Mirror"
        Case Rotate90Clockwise
            GetNameOfProcess = "Rotate 90� Clockwise"
        Case Rotate180
            GetNameOfProcess = "Rotate 180�"
        Case Rotate270Clockwise
            GetNameOfProcess = "Rotate 90� Counter-Clockwise"
        Case FreeRotate
            GetNameOfProcess = "Arbitrary Rotation"
        Case Isometric
            GetNameOfProcess = "Isometric Conversion"
        Case Tile
            GetNameOfProcess = "Tile Image"
        Case CropToSelection
            GetNameOfProcess = "Crop"
        Case ChangeImageMode24
            GetNameOfProcess = "Convert to Photo Mode (RGB, 24bpp)"
        Case ChangeImageMode32
            GetNameOfProcess = "Convert to Web Mode (RGBA, 32bpp)"
            
        'Miscellaneous filters; numbers 800-899
        Case Fade
            GetNameOfProcess = "Fade"
        Case Unfade
            GetNameOfProcess = "Unfade"
        Case Atmospheric
            GetNameOfProcess = "Atmosphere"
        Case Frozen
            GetNameOfProcess = "Freeze"
        Case Lava
            GetNameOfProcess = "Lava"
        Case Burn
            GetNameOfProcess = "Burn"
        Case Ocean
            GetNameOfProcess = "Ocean"
        Case Water
            GetNameOfProcess = "Water"
        Case Steel
            GetNameOfProcess = "Steel"
        Case Dream
            GetNameOfProcess = "Dream"
        Case Alien
            GetNameOfProcess = "Alien"
        Case CustomFilter
            GetNameOfProcess = "Custom Filter"
        Case Antique
            GetNameOfProcess = "Antique"
        Case BlackLight
            GetNameOfProcess = "Blacklight"
        Case Posterize
            GetNameOfProcess = "Posterize"
        Case Radioactive
            GetNameOfProcess = "Radioactive"
        Case Solarize
            GetNameOfProcess = "Solarize"
        Case Twins
            GetNameOfProcess = "Generate Twins"
        Case Synthesize
            GetNameOfProcess = "Synthesize"
        Case Noise
            GetNameOfProcess = "Add Noise"
        Case CountColors
            GetNameOfProcess = "Count Image Colors"
        Case FogEffect
            GetNameOfProcess = "Fog"
        Case Rainbow
            GetNameOfProcess = "Rainbow"
        Case Vibrate
            GetNameOfProcess = "Vibrate"
        Case Despeckle
            GetNameOfProcess = "Despeckle"
        Case CustomDespeckle
            GetNameOfProcess = "Custom Despeckle"
        Case Animate
            GetNameOfProcess = "Animate"
        Case Sepia
            GetNameOfProcess = "Sepia"
        Case HeatMap
            GetNameOfProcess = "Thermograph (Heat Map)"
        
        Case LastCommand
            GetNameOfProcess = "Repeat Last Action"
        Case FadeLastEffect
            GetNameOfProcess = "Fade last effect"
            
        Case SelectionCreate
            GetNameOfProcess = "Create New Selection"
        Case SelectionClear
            GetNameOfProcess = "Clear Active Selection"
            
        'This "Else" statement should never trigger, but if it does, return an empty string
        Case Else
            GetNameOfProcess = ""
            
    End Select
    
End Function
