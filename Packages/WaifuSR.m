(* ::Package:: *)
(* ::Title:: *)
(*WaifuSR(WaifuSR)*)
(* ::Subchapter:: *)
(*程序包介绍*)
(* ::Text:: *)
(*Mathematica Package*)
(*Created by Mathematica Plugin for IntelliJ IDEA*)
(*Establish from GalAster's template(v1.3)*)
(**)
(* ::Text:: *)
(*Author:Aster*)
(*Creation Date:2018-08-21*)
(*Copyright: Mozilla Public License Version 2.0*)
(* ::Program:: *)
(*1.软件产品再发布时包含一份原始许可声明和版权声明。*)
(*2.提供快速的专利授权。*)
(*3.不得使用其原始商标。*)
(*4.如果修改了源代码，包含一份代码修改说明。*)
(**)
(* ::Text:: *)
(*这里应该填这个函数的介绍*)
(* ::Section:: *)
(*函数说明*)
WaifuSR::usage = "";
(* ::Section:: *)
(*程序包正体*)
(* ::Subsection::Closed:: *)
(*主设置*)
Begin["`WaifuSR`"];
(* ::Subsection::Closed:: *)
(*主体代码*)
Version$WaifuSR = "V1.0";
Updated$WaifuSR = "2018-08-21";
rgbMatrix = {{0.257, 0.504, 0.098}, {-0.148, -0.291, 0.439}, {0.439, -0.368, -0.071}};
rgbMatrixT = {{1.164, 0., 1.596}, {1.164, -0.392, -0.813}, {1.164, 2.017, 0.}};
WaifuNearset = ImageResize[#, {512, 512}, Resampling -> "Nearest"] &;
WaifuLinear = ImageResize[#, {512, 512}, Resampling -> "Linear"] &;
WaifuCubic = ImageResize[#, {512, 512}, Resampling -> "Cubic"] &;
WaifuOMOMS = ImageResize[#, {512, 512}, Resampling -> {"OMOMS", 7}] &;
Waifu`Models`LapSRN := Ready[$Waifus["LapSRN2x", "Remote"]];
Waifu`Models`LapSRN2 := Ready[$Waifus["LapSRN4x", "Remote"]];
Waifu`Models`RED30 := Ready[$Waifus["RED30-SR", "Remote"]];
Waifu`Models`VDSR := Ready[$Waifus["VDSR", "Remote"]];
Waifu`Models`SESR := Ready[$Waifus["SESR", "Remote"]];
Waifu`Models`VGGSR := Ready[$Waifus["VGGSR", "Remote"]];
Waifu`Models`ByNet := Ready[$Waifus["ByNet9", "Remote"]];
(* ::Subsubsection::Closed:: *)
(*LapSRN*)
WaifuLapSRN[img_, zoom_ : 2, device_ : "GPU"] := Block[
	{render},
	If[MissingQ[Waifu`Models`LapSRN], Return[Missing["NotAvailable"]]];
	render[channel_] := Image[NetReplacePart[Waifu`Models`LapSRN, {
		"Input" -> NetEncoder[{"Image", ImageDimensions@img, ColorSpace -> "Grayscale"}]
	}][channel, TargetDevice -> device]];
	ColorCombine[render /@ ColorSeparate[img]]
];
WaifuLapSRN2[img_, zoom_ : 2, device_ : "GPU"] := Block[
	{render},
	If[MissingQ[Waifu`Models`LapSRN2], Return[Missing["NotAvailable"]]];
	render[channel_] := Image[NetReplacePart[Waifu`Models`LapSRN2, {
		"Input" -> NetEncoder[{"Image", ImageDimensions@img, ColorSpace -> "Grayscale"}]
	}][channel, TargetDevice -> device]];
	ColorCombine[render /@ ColorSeparate[img]]
];


(* ::Subsubsection::Closed:: *)
(*RED30*)
WaifuRED30[img_, zoom_ : 2, device_ : "GPU"] := Block[
	{upsample, ycbcr, channels, netResize, adjust},
	If[MissingQ[Waifu`Models`RED30], Return[Missing["NotAvailable"]]];
	upsample = ImageResize[img, Scaled[zoom], Resampling -> "Cubic"];
	ycbcr = ImageApply[rgbMatrix.# + {0.063, 0.502, 0.502}&, upsample];
	netResize = NetReplacePart[Waifu`Models`RED30,
		"Input" -> NetEncoder[{"Image", ImageDimensions@upsample, ColorSpace -> "Grayscale"}]
	];
	adjust = ColorCombine[{#1 + Image@netResize[#1, TargetDevice -> device], #2, #3}]&;
	ImageApply[rgbMatrixT.# + {-0.874, 0.532, -1.086}&, adjust @@ ColorSeparate[ycbcr]]
];



(* ::Subsubsection::Closed:: *)
(*VDSR*)
WaifuVDSR[img_, zoom_ : 2, device_ : "GPU"] := Block[
	{upsample, ycbcr, channels, netResize, adjust},
	If[MissingQ[Waifu`Models`VDSR], Return[Missing["NotAvailable"]]];
	upsample = ImageResize[img, Scaled[zoom], Resampling -> "Cubic"];
	ycbcr = ImageApply[rgbMatrix.# + {0.063, 0.502, 0.502}&, upsample];
	netResize = NetReplacePart[Waifu`Models`VDSR,
		"Input" -> NetEncoder[{"Image", ImageDimensions@upsample, ColorSpace -> "Grayscale"}]
	];
	adjust = ColorCombine[{#1 + Image@netResize[#1, TargetDevice -> device], #2, #3}]&;
	ImageApply[rgbMatrixT.# + {-0.874, 0.532, -1.086}&, adjust @@ ColorSeparate[ycbcr]]
];



(* ::Subsubsection::Closed:: *)
(*ByNet+*)
WaifuByNet[img_, zoom_ : 2, device_ : "GPU"] := Block[
	{upsample, ycbcr, channels, netResize, adjust},
	If[MissingQ[Waifu`Models`ByNet], Return[Missing["NotAvailable"]]];
	upsample = ImageResize[img, Scaled[zoom], Resampling -> "Cubic"];
	ycbcr = ImageApply[rgbMatrix.# + {0.063, 0.502, 0.502}&, upsample];
	netResize = NetReplacePart[Waifu`Models`ByNet,
		"Input" -> NetEncoder[{"Image", ImageDimensions@upsample, ColorSpace -> "Grayscale"}]
	];
	adjust = ColorCombine[{#1 + Image@netResize[#1, TargetDevice -> device], #2, #3}]&;
	ImageApply[rgbMatrixT.# + {-0.874, 0.532, -1.086}&, adjust @@ ColorSeparate[ycbcr]]
];



(* ::Subsubsection::Closed:: *)
(*VGGSR*)
WaifuVGGSR[img_, device_ : "GPU"] := Module[
	{covImg, covNet, x, y},
	If[MissingQ[Waifu`Models`VGGSR], Return[Missing["NotAvailable"]]];
	{x, y} = ImageDimensions[img];
	covImg = ColorCombine[Reverse@ColorSeparate[ImageResize[img, {x + 14, y + 14}]]];
	covNet = NetReplacePart[Waifu`Models`VGGSR, "Input" -> NetEncoder[{"Image", ImageDimensions@covImg}]];
	covNet[covImg, TargetDevice -> device]
];



(* ::Subsubsection::Closed:: *)
(*SESR*)
WaifuSESR[img_, device_ : "GPU"] := Block[
	{upsample, ycbcr, netResize, adjust},
	If[MissingQ[Waifu`Models`SESR], Return[Missing["NotAvailable"]]];
	upsample = ImageResize[img, Scaled[2], Resampling -> "Cubic"];
	ycbcr = ImageApply[rgbMatrix.# + {0.063, 0.502, 0.502}&, upsample];
	netResize = NetReplacePart[Waifu`Models`SESR, {
		"Input" -> NetEncoder[{"Image", ImageDimensions@img, ColorSpace -> "Grayscale"}]
	}];
	adjust = ColorCombine[{Image@netResize[#1, TargetDevice -> device], #2, #3}]&;
	ImageApply[rgbMatrixT.# + {-0.874, 0.532, -1.086}&, adjust @@ ColorSeparate[ycbcr]]
];


Options[WaifuSR] = {TargetDevice -> "GPU"};
WaifuSR[i_Image, zoom_ : 2, OptionsPattern[]] := Block[
	{
		device = OptionValue[TargetDevice],
		img = ColorConvert[RemoveAlphaChannel@i, "RGB"]
	},
	If[Or @@ {
		MissingQ[Waifu`Models`LapSRN],
		MissingQ[Waifu`Models`LapSRN2]
	},
		Return[Missing["NotAvailable"]]
	];
	Piecewise[{
		{Return[$Failed], zoom <= 1},
		{ImageResize[WaifuLapSRN[img, device], zoom ImageDimensions[i]], 1 < zoom <= 2},
		{ImageResize[WaifuLapSRN2[img, device], zoom ImageDimensions[i]], 2 < zoom <= 4},
		{ImageResize[img, Scaled[zoom], Resampling -> {"OMOMS", 7}], 4 < zoom}
	}]
];
(* ::Subsection::Closed:: *)
(*附加设置*)
SetAttributes[
	{WaifuSR},
	{Protected, ReadProtected}
];
End[]
