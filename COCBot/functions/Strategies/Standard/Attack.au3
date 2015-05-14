; Improved attack algorithm, using Barbarians, Archers, Goblins, Giants and Wallbreakers as they are available
; Create by Fast French, edited by safar46

Func Standard_SetSleep($type)
	Switch $type
		Case 0
			If $iRandomspeedatk = 1 Then
				Return Round(Random(1, 10)) * 10
			Else
				Return ($icmbUnitDelay + 1) * 10
			EndIf
		Case 1
			If $iRandomspeedatk = 1 Then
				Return Round(Random(1, 10)) * 100
			Else
				Return ($icmbWaveDelay + 1) * 100
			EndIf
	EndSwitch
EndFunc   ;==>Standard_SetSleep

; Old mecanism, not used anymore
Func Standard_OldDropTroop($troup, $position, $nbperspot)
	SelectDropTroupe($troup) ;Select Troop
	If _Sleep(100) Then Return
	For $i = 0 To 4
		Click($position[$i][0], $position[$i][1], $nbperspot, 1)
		If _Sleep(50) Then Return
	Next
EndFunc   ;==>OldDropTroop

; improved function, that avoids to only drop on 5 discret drop points :
Func Standard_DropOnEdge($troop, $edge, $number, $slotsPerEdge = 0, $edge2 = -1, $x = -1, $Center = 1)
	Switch $troop
		Case $eBarbarian
			$Pen = $pBarbarian
		Case $eArcher
			$Pen = $pArcher
		Case $eGoblin
			$Pen = $pGoblin
		Case $eGiant
			$Pen = $pGiant
		Case $eWallbreaker
			$Pen = $pWallB
	EndSwitch
	If $number = 0 Then Return
	If _Sleep(100) Then Return
	SelectDropTroupe($troop) ;Select Troop
	If _Sleep(300) Then Return
	If $slotsPerEdge = 0 Or $number < $slotsPerEdge Then $slotsPerEdge = $number
	If $number = 1 Or $slotsPerEdge = 1 Then ; Drop on a single point per edge => on the middle
		Click($edge[2][0], $edge[2][1], $number, 0, $Center)
		If $edge2 <> -1 Then Click($edge2[2][0], $edge2[2][1], $number, 0, $Center)
		If _Sleep(50) Then Return
	ElseIf $slotsPerEdge = 2 Then ; Drop on 2 points per edge
		Local $half = Ceiling($number / 2)
		Click($edge[1][0], $edge[1][1], $half, 0, $Center)
		If $edge2 <> -1 Then
			If _Sleep(Standard_SetSleep(0)) Then Return
			Click($edge2[1][0], $edge2[1][1], $half, 0, $Center)
		EndIf
		If _Sleep(Standard_SetSleep(0)) Then Return
		Click($edge[3][0], $edge[3][1], $number - $half, 0, $Center)
		If $edge2 <> -1 Then
			If _Sleep(Standard_SetSleep(0)) Then Return
			Click($edge2[3][0], $edge2[3][1], $number - $half, 0, $Center)
		EndIf
		If _Sleep(Standard_SetSleep(0)) Then Return
	Else
		Local $minX = $edge[0][0]
		Local $maxX = $edge[4][0]
		Local $minY = $edge[0][1]
		Local $maxY = $edge[4][1]
		If $edge2 <> -1 Then
			Local $minX2 = $edge2[0][0]
			Local $maxX2 = $edge2[4][0]
			Local $minY2 = $edge2[0][1]
			Local $maxY2 = $edge2[4][1]
		EndIf
		Local $nbTroopsLeft = $number
		For $i = 0 To $slotsPerEdge - 1
			Local $nbtroopPerSlot = Round($nbTroopsLeft / ($slotsPerEdge - $i)) ; progressively adapt the number of drops to fill at the best
			Local $posX = $minX + (($maxX - $minX) * $i) / ($slotsPerEdge - 1)
			Local $posY = $minY + (($maxY - $minY) * $i) / ($slotsPerEdge - 1)
			; Randomize the drop points a bit more
			$posX = Round(_Random_Gaussian($posX, 1.5))
			$posY = Round(_Random_Gaussian($posY, 1.5))
			Click($posX, $posY, $nbtroopPerSlot, 0, $Center)
			If $edge2 <> -1 Then ; for 2, 3 and 4 sides attack use 2x dropping
				Local $posX2 = $maxX2 - (($maxX2 - $minX2) * $i) / ($slotsPerEdge - 1)
				Local $posY2 = $maxY2 - (($maxY2 - $minY2) * $i) / ($slotsPerEdge - 1)
				; Randomize the drop points a bit more
				$posX2 = Round(_Random_Gaussian($posX2, 1.5))
				$posY2 = Round(_Random_Gaussian($posY2, 1.5))
				If $x = 0 Then
					If _Sleep(Standard_SetSleep(0)) Then Return ; add delay for first wave attack to prevent skip dropping troops, must add for 4 sides attack
				EndIf
				Click($posX2, $posY2, $nbtroopPerSlot, 0, $Center)
				$nbTroopsLeft -= $nbtroopPerSlot
			Else
				$nbTroopsLeft -= $nbtroopPerSlot
			EndIf
			If _Sleep(Standard_SetSleep(0)) Then Return
		Next
	EndIf
EndFunc   ;==>Standard_DropOnEdge

Func Standard_DropOnEdges($troop, $nbSides, $number, $slotsPerEdge = 0, $miniEdge = False)
	If $nbSides = 0 Or $number = 1 Then
		Standard_OldDropTroop($troop, $Edges[0], $number);
		Return
	EndIf
	If $nbSides < -1 Then Return
	Local $nbTroopsLeft = $number
	If Not $miniEdge Then
		If $nbSides = 4 Then
			For $i = 0 To $nbSides - 3
				Local $nbTroopsPerEdge = Round($nbTroopsLeft / ($nbSides - $i * 2))
				Standard_DropOnEdge($troop, $Edges[$i], $nbTroopsPerEdge, $slotsPerEdge, $Edges[$i + 2], $i)
				$nbTroopsLeft -= $nbTroopsPerEdge * 2
			Next
			Return
		EndIf
		For $i = 0 To $nbSides - 1
			If $nbSides = 1 Or ($nbSides = 3 And $i = 2) Then
				Local $nbTroopsPerEdge = Round($nbTroopsLeft / ($nbSides - $i))
				Standard_DropOnEdge($troop, $Edges[$i], $nbTroopsPerEdge, $slotsPerEdge)
				$nbTroopsLeft -= $nbTroopsPerEdge
			ElseIf ($nbSides = 2 And $i = 0) Or ($nbSides = 3 And $i <> 1) Then
				Local $nbTroopsPerEdge = Round($nbTroopsLeft / ($nbSides - $i * 2))
				Standard_DropOnEdge($troop, $Edges[$i + 3], $nbTroopsPerEdge, $slotsPerEdge, $Edges[$i + 1])
				$nbTroopsLeft -= $nbTroopsPerEdge * 2
			EndIf
		Next
	Else
		Switch $THquadrant
			Case 1
				Local $edgeA[5][2] = [[$FurthestTopLeft[0][0], $FurthestTopLeft[0][1]], [0, 0], [0, 0], [0, 0], [Round(($FurthestTopLeft[4][0] - $FurthestTopLeft[0][0]) / _Random_Gaussian(4.5, .25)) + $FurthestTopLeft[0][0], Round(($FurthestTopLeft[4][1] - $FurthestTopLeft[0][1]) / _Random_Gaussian(4.5, .25)) + $FurthestTopLeft[0][1]]]
				Local $edgeB[5][2] = [[$FurthestBottomLeft[0][0], $FurthestBottomLeft[0][1]], [0, 0], [0, 0], [0, 0], [Round(($FurthestBottomLeft[4][0] - $FurthestBottomLeft[0][0]) / _Random_Gaussian(4.5, .25)) + $FurthestBottomLeft[0][0], Round(($FurthestBottomLeft[4][1] - $FurthestBottomLeft[0][1]) / _Random_Gaussian(4.5, .25)) + $FurthestBottomLeft[0][1]]]
				$nbSides = 2
			Case 2
				$m = (537 - 238) / (535 - 128)
				$m2 = (9 - 314) / (430 - 28)
				$b = $THy - ($m * $THx)
				$b2 = 314 - ($m2 * 28)
				$CenterX = ($b - $b2) / ($m2 - $m)
				$LeftX = Round(_Random_Gaussian($CenterX - 20, 3))
				$RightX = Round(_Random_Gaussian($CenterX + 20, 3))
				If $LeftX < $FurthestTopLeft[0][0] Then $LeftX = $FurthestTopLeft[0][0]
				If $RightX > $FurthestTopLeft[4][0] Then $RightX = $FurthestTopLeft[4][0]
				$LeftY = Round($m2 * $LeftX + $b2)
				$RightY = Round($m2 * $RightX + $b2)
				Local $edgeA[5][2] = [[$LeftX, $LeftY], [0, 0], [0, 0], [0, 0], [$RightX, $RightY]]
				Local $edgeB = -1
				$nbSides = 1
			Case 3
				Local $edgeA[5][2] = [[$FurthestTopLeft[4][0], $FurthestTopLeft[4][1]], [0, 0], [0, 0], [0, 0], [$FurthestTopLeft[4][0] - Round(($FurthestTopLeft[4][0] - $FurthestTopLeft[0][0]) / _Random_Gaussian(4.5, .25)), $FurthestTopLeft[4][1] - Round(($FurthestTopLeft[4][1] - $FurthestTopLeft[0][1]) / _Random_Gaussian(4.5, .25))]]
				Local $edgeB[5][2] = [[$FurthestTopRight[0][0], $FurthestTopRight[0][1]], [0, 0], [0, 0], [0, 0], [Round(($FurthestTopRight[4][0] - $FurthestTopRight[0][0]) / _Random_Gaussian(4.5, .25)) + $FurthestTopRight[0][0], Round(($FurthestTopRight[4][1] - $FurthestTopRight[0][1]) / _Random_Gaussian(4.5, .25)) + $FurthestTopRight[0][1]]]
				$nbSides = 2
			Case 4
				$m = (85 - 388) / (527 - 130)
				$m2 = (612 - 314) / (440 - 28)
				$b = $THy - ($m * $THx)
				$b2 = 314 - ($m2 * 28)
				$CenterX = ($b - $b2) / ($m2 - $m)
				$LeftX = Round(_Random_Gaussian($CenterX - 20, 3))
				$RightX = Round(_Random_Gaussian($CenterX + 20, 3))
				If $LeftX < $FurthestBottomLeft[0][0] Then $LeftX = $FurthestBottomLeft[0][0]
				If $RightX > (.75 * ($FurthestBottomLeft[4][0] - $FurthestBottomLeft[0][0])) + $FurthestBottomLeft[0][0] Then $RightX = Round((.75 * ($FurthestBottomLeft[4][0] - $FurthestBottomLeft[0][0])) + $FurthestBottomLeft[0][0])
				$LeftY = Round($m2 * $LeftX + $b2)
				$RightY = Round($m2 * $RightX + $b2)
				Local $edgeA[5][2] = [[$LeftX, $LeftY], [0, 0], [0, 0], [0, 0], [$RightX, $RightY]]
				Local $edgeB = -1
				$nbSides = 1
			Case 6
				$m = (85 - 388) / (527 - 130)
				$m2 = (313 - 9) / (820 - 430)
				$b = $THy - ($m * $THx)
				$b2 = 9 - ($m2 * 430)
				$CenterX = ($b - $b2) / ($m2 - $m)
				$LeftX = Round(_Random_Gaussian($CenterX - 20, 3))
				$RightX = Round(_Random_Gaussian($CenterX + 20, 3))
				If $LeftX < $FurthestTopRight[0][0] Then $LeftX = $FurthestTopRight[0][0]
				If $RightX > $FurthestTopRight[4][0] Then $RightX = $FurthestTopRight[4][0]
				$LeftY = Round($m2 * $LeftX + $b2)
				$RightY = Round($m2 * $RightX + $b2)
				Local $edgeA[5][2] = [[$LeftX, $LeftY], [0, 0], [0, 0], [0, 0], [$RightX, $RightY]]
				Local $edgeB = -1
				$nbSides = 1
			Case 7
				Local $edgeA[5][2] = [[Round(($FurthestBottomRight[4][0] - $FurthestBottomRight[0][0]) / 3.5) + $FurthestBottomRight[0][0], Round(($FurthestBottomRight[4][1] - $FurthestBottomRight[0][1]) / 3.5) + $FurthestBottomRight[0][1]], [0, 0], [0, 0], [0, 0], [Round(($FurthestBottomRight[4][0] - $FurthestBottomRight[0][0]) / 4) + $FurthestBottomRight[0][0], Round(($FurthestBottomRight[4][1] - $FurthestBottomRight[0][1]) / 4) + $FurthestBottomRight[0][1]]]
				Local $edgeB[5][2] = [[$FurthestBottomLeft[4][0] - Round(($FurthestBottomLeft[4][0] - $FurthestBottomLeft[0][0]) / 3.5), $FurthestBottomLeft[4][1] - Round(($FurthestBottomLeft[4][1] - $FurthestBottomLeft[0][1]) / 3.5)], [0, 0], [0, 0], [0, 0], [$FurthestBottomLeft[4][0] - Round(($FurthestBottomLeft[4][0] - $FurthestBottomLeft[0][0]) / 4), $FurthestBottomLeft[4][1] - Round(($FurthestBottomLeft[4][1] - $FurthestBottomLeft[0][1]) / 4)]]
				$nbSides = 2
			Case 8
				$m = (537 - 238) / (535 - 128)
				$m2 = (9 - 314) / (430 - 28)
				If $m = $m2 Then $m2 = $m2 + 0.00000001
				$b = $THy - ($m * $THx)
				$b2 = 612 - ($m2 * 440)
				$CenterX = ($b - $b2) / ($m2 - $m)
				$LeftX = Round(_Random_Gaussian($CenterX - 20, 3))
				$RightX = Round(_Random_Gaussian($CenterX + 20, 3))
				If $LeftX < ((.25 * ($FurthestBottomRight[4][0] - $FurthestBottomRight[0][0])) + $FurthestBottomRight[0][0]) Then $LeftX = Round(((.25 * ($FurthestBottomRight[4][0] - $FurthestBottomRight[0][0])) + $FurthestBottomRight[0][0]))
				If $RightX > $FurthestBottomRight[4][0] Then $RightX = $FurthestBottomRight[4][0]
				$LeftY = Round($m2 * $LeftX + $b2)
				$RightY = Round($m2 * $RightX + $b2)
				Local $edgeA[5][2] = [[$LeftX, $LeftY], [0, 0], [0, 0], [0, 0], [$RightX, $RightY]]
				Local $edgeB = -1
				$nbSides = 1
			Case 9
				Local $edgeA[5][2] = [[$FurthestTopRight[4][0], $FurthestTopRight[4][1]], [0, 0], [0, 0], [0, 0], [$FurthestTopRight[4][0] - Round(($FurthestTopRight[4][0] - $FurthestTopRight[0][0]) / _Random_Gaussian(4.5, .25)), $FurthestTopRight[4][1] - Round(($FurthestTopRight[4][1] - $FurthestTopRight[0][1]) / _Random_Gaussian(4.5, .25))]]
				Local $edgeB[5][2] = [[$FurthestBottomRight[4][0], $FurthestBottomRight[4][1]], [0, 0], [0, 0], [0, 0], [$FurthestBottomRight[4][0] - Round(($FurthestBottomRight[4][0] - $FurthestBottomRight[0][0]) / _Random_Gaussian(4.5, .25)), $FurthestBottomRight[4][1] - Round(($FurthestBottomRight[4][1] - $FurthestBottomRight[0][1]) / _Random_Gaussian(4.5, .25))]]
				$nbSides = 2
			Case Else
				Return
		EndSwitch
		$edgeA[2][0] = Round(($edgeA[0][0] + $edgeA[4][0]) / 2)
		$edgeA[2][1] = Round(($edgeA[0][1] + $edgeA[4][1]) / 2)
		$edgeA[1][0] = Round(($edgeA[0][0] + $edgeA[2][0]) / 2)
		$edgeA[1][1] = Round(($edgeA[0][1] + $edgeA[2][1]) / 2)
		$edgeA[3][0] = Round(($edgeA[2][0] + $edgeA[4][0]) / 2)
		$edgeA[3][1] = Round(($edgeA[2][1] + $edgeA[4][1]) / 2)
		If $edgeB <> -1 Then
			$edgeB[2][0] = Round(($edgeB[0][0] + $edgeB[4][0]) / 2)
			$edgeB[2][1] = Round(($edgeB[0][1] + $edgeB[4][1]) / 2)
			$edgeB[1][0] = Round(($edgeB[0][0] + $edgeB[2][0]) / 2)
			$edgeB[1][1] = Round(($edgeB[0][1] + $edgeB[2][1]) / 2)
			$edgeB[3][0] = Round(($edgeB[2][0] + $edgeB[4][0]) / 2)
			$edgeB[3][1] = Round(($edgeB[2][1] + $edgeB[4][1]) / 2)
		EndIf
		If $nbSides = 1 Then
			Standard_DropOnEdge($troop, $edgeA, $nbTroopsLeft, $slotsPerEdge, -1, -1, $AimTH)
			$nbTroopsLeft = 0
		Else
			$nbTroopsPerEdge = Round($nbTroopsLeft / 2)
			Standard_DropOnEdge($troop, $edgeA, $nbTroopsPerEdge, $slotsPerEdge, $edgeB, -1, $AimTH)
		EndIf
	EndIf
EndFunc   ;==>Standard_DropOnEdges

Func Standard_LaunchTroop($troopKind, $nbSides, $waveNb, $maxWaveNb, $slotsPerEdge = 0, $miniEdge = False)
	Local $troop = -1
	Local $troopNb = 0
	Local $name = ""
	For $i = 0 To 8 ; identify the position of this kind of troop
		If $atkTroops[$i][0] = $troopKind Then
			$troop = $i
			$troopNb = Ceiling($atkTroops[$i][1] / $maxWaveNb)
			Local $plural = 0
			If $troopNb > 1 Then $plural = 1
			$name = NameOfTroop($troopKind, $plural)
		EndIf
	Next

	If ($troop = -1) Or ($troopNb = 0) Then
		Return False; nothing to do => skip this wave
	EndIf

	Local $waveName = "first"
	If $waveNb = 2 Then $waveName = "second"
	If $waveNb = 3 Then $waveName = "third"
	If $maxWaveNb = 1 Then $waveName = "only"
	If $waveNb = 0 Then $waveName = "last"
	SetLog("Dropping " & $waveName & " wave of " & $troopNb & " " & $name, $COLOR_BLUE)
	Standard_DropOnEdges($troop, $nbSides, $troopNb, $slotsPerEdge, $miniEdge)
	Return True
EndFunc   ;==>Standard_LaunchTroop

Func Standard_Attack($AttackMethod = 1)

	_CaptureRegion()
	$hAttackBitmap = _GDIPlus_BitmapCloneArea($hBitmap, 0, 0, 860, 720, _GDIPlus_ImageGetPixelFormat($hBitmap))
	$Buffer = _GDIPlus_ImageGetGraphicsContext($hAttackBitmap)
	$pBarbarian = _GDIPlus_PenCreate(0xFFF8E53C, 1)
	$pArcher = _GDIPlus_PenCreate(0xFFEA4170, 1)
	$pGoblin = _GDIPlus_PenCreate(0xFF98F05C, 1)
	$pGiant = _GDIPlus_PenCreate(0xFFA06960, 1)
	$pWallB = _GDIPlus_PenCreate(0xFF504448, 1)
	$pLightning = _GDIPlus_PenCreate(0xFF0C46E8, 1)
	$pKing = _GDIPlus_PenCreate(0xFFA03C40, 1)
	$pQueen = _GDIPlus_PenCreate(0xFF9D58E9, 1)
	$pCC = _GDIPlus_PenCreate(0xFFFEF8F7, 1)

	If $ichkAvoidEdge = 1 Then SeekEdges()

	If $AttackMethod = 2 Then
		SetLog("~Nuking the dark elixir storage", $COLOR_BLUE)
		Standard_DropNukes()
		If _Sleep(5000) Then Return
	Else
		$King = -1
		$Queen = -1
		$LSpell = -1
		$SpellQty = 0
		$CC = -1
		$Barb = -1
		$Arch = -1
		For $i = 0 To 8
			If $atkTroops[$i][0] = $eBarbarian Then
				$Barb = $i
			ElseIf $atkTroops[$i][0] = $eArcher Then
				$Arch = $i
			ElseIf $atkTroops[$i][0] = $eCastle Then
				$CC = $i
			ElseIf $atkTroops[$i][0] = $eKing Then
				$King = $i
			ElseIf $atkTroops[$i][0] = $eQueen Then
				$Queen = $i
			ElseIf $atkTroops[$i][0] = $eLSpell Then
				$LSpell = $i
				$SpellQty = $atkTroops[$i][1]
			EndIf
		Next

		If _Sleep(2000) Then Return
		Local $nbSides = 0
		Local $mixedMode = False

		$attackTH = ($AttackMethod = 0) ? _GUICtrlComboBox_GetCurSel($cmbDeadAttackTH) : _GUICtrlComboBox_GetCurSel($cmbAttackTH)
		Local $OuterQuad
		$OuterQuad = False
		If $THquadrant >= 1 And $THquadrant <= 4 Then $OuterQuad = True
		If $THquadrant >= 6 And $THquadrant <= 9 Then $OuterQuad = True
		If ($OuterQuad And $attackTH = 2) Then
			SetLog("~Attacking townhall...")
			$nbSides = -1
		Else
			If $AttackMethod = 0 Then
				Switch _GUICtrlComboBox_GetCurSel($cmbDeadDeploy)
					Case 0 ;Single sides ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
						SetLog("~Attacking in a single side...")
						$nbSides = 1
					Case 1 ;Two sides ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
						SetLog("~Attacking in two sides...")
						$nbSides = 2
					Case 2 ;Three sides ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
						SetLog("~Attacking in three sides...")
						$nbSides = 3
					Case 3 ;Four sides ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
						SetLog("~Attacking in all sides...")
						$nbSides = 4
					Case 4
						SetLog("~Mixed mode attacking...")
						$nbSides = 4
						$mixedMode = True
				EndSwitch
			Else
				Switch _GUICtrlComboBox_GetCurSel($cmbDeploy)
					Case 0 ;Single sides ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
						SetLog("~Attacking in a single side...")
						$nbSides = 1
					Case 1 ;Two sides ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
						SetLog("~Attacking in two sides...")
						$nbSides = 2
					Case 2 ;Three sides ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
						SetLog("~Attacking in three sides...")
						$nbSides = 3
					Case 3 ;Four sides ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
						SetLog("~Attacking in all sides...")
						$nbSides = 4
					Case 4
						SetLog("~Mixed mode attacking...")
						$nbSides = 4
						$mixedMode = True
				EndSwitch
			EndIf
			If ($OuterQuad And $attackTH = 1) Then SetLog("~With limited townhall attack...")
			If ($nbSides = 0) Then Return
		EndIf
		If _Sleep(1000) Then Return

		; ================================================================================?
		; ========= Here is coded the main attack strategy ===============================
		; ========= Feel free to experiment something else ===============================
		; ================================================================================?
		If Standard_LaunchTroop($eGiant, (($mixedMode) ? 1 : $nbSides), 1, 1, 1, ($OuterQuad And $attackTH = 2)) Then
			If _Sleep(Standard_SetSleep(1)) Then Return
		EndIf
		If Standard_LaunchTroop($eHog, (($mixedMode) ? 1 : $nbSides), 1, 1, 1, ($OuterQuad And $attackTH = 2)) Then
			If _Sleep(Standard_SetSleep(1)) Then Return
		EndIf
		If Not $mixedMode Then
			If Standard_LaunchTroop($eValkyrie, $nbSides, 1, 1, 1, ($OuterQuad And $attackTH = 2)) Then
				If _Sleep(Standard_SetSleep(1)) Then Return
			EndIf
		EndIf
		If Standard_LaunchTroop($eBarbarian, $nbSides, 1, 2, 0, ($OuterQuad And $attackTH = 2)) Then
			If _Sleep(Standard_SetSleep(1)) Then Return
		EndIf
		If Standard_LaunchTroop($eWallbreaker, (($mixedMode) ? 1 : $nbSides), 1, (($mixedMode) ? 3 : 1), 1, ($OuterQuad And $attackTH = 2)) Then
			If _Sleep(Standard_SetSleep(1)) Then Return
		EndIf
		If Standard_LaunchTroop($eArcher, $nbSides, 1, 2, 0, ($OuterQuad And $attackTH = 2)) Then
			If _Sleep(Standard_SetSleep(1)) Then Return
		EndIf
		If Standard_LaunchTroop($eBarbarian, (($mixedMode) ? 1 : $nbSides), 2, 2, 0, ($OuterQuad And $attackTH >= 1)) Then
			If _Sleep(Standard_SetSleep(1)) Then Return
		EndIf
		If Standard_LaunchTroop($eGoblin, $nbSides, 1, 2, 0, ($OuterQuad And $attackTH = 2)) Then
			If _Sleep(Standard_SetSleep(1)) Then Return
		EndIf
		If $mixedMode Then
			If Standard_LaunchTroop($eWallbreaker, 1, 2, 3, 1) Then
				If _Sleep(Standard_SetSleep(1), False) Then Return
			EndIf
		Else
			If Standard_LaunchTroop($eArcher, $nbSides, 2, 2, 0, ($OuterQuad And $attackTH >= 1)) Then
				If _Sleep(Standard_SetSleep(1)) Then Return
			EndIf
			If Standard_LaunchTroop($eGoblin, $nbSides, 2, 2, 0, ($OuterQuad And $attackTH = 2)) Then
				If _Sleep(Standard_SetSleep(1)) Then Return
			EndIf
			If Standard_LaunchTroop($eMinion, $nbSides, 1, 1, 0, ($OuterQuad And $attackTH = 2)) Then
				If _Sleep(Standard_SetSleep(1)) Then Return
			EndIf
		EndIf
		; ================================================================================?

		$hHeroTimer = ""
		; Deploy CC and Heroes behind troops
		If ($OuterQuad And $attackTH = 2) Then
			Switch $THquadrant
				Case 1
					$DropX = $FurthestTopLeft[0][0]
					$DropY = $FurthestTopLeft[0][1]
				Case 2
					$m = (537 - 238) / (535 - 128)
					$m2 = (9 - 314) / (430 - 28)
					$b = $THy - ($m * $THx)
					$b2 = 314 - ($m2 * 28)
					$DropX = ($b - $b2) / ($m2 - $m)
					$DropY = Round($m2 * $DropX + $b2)
				Case 3
					$DropX = $FurthestTopLeft[4][0]
					$DropY = $FurthestTopLeft[4][1]
				Case 4
					$m = (85 - 388) / (527 - 130)
					$m2 = (612 - 314) / (440 - 28)
					$b = $THy - ($m * $THx)
					$b2 = 314 - ($m2 * 28)
					$DropX = ($b - $b2) / ($m2 - $m)
					$DropY = Round($m2 * $DropX + $b2)
				Case 6
					$m = (85 - 388) / (527 - 130)
					$m2 = (612 - 314) / (440 - 28)
					$b = $THy - ($m * $THx)
					$b2 = 9 - ($m2 * 430)
					$DropX = ($b - $b2) / ($m2 - $m)
					$DropY = Round($m2 * $DropX + $b2)
				Case 7
					$DropX = Round(($FurthestBottomRight[4][0] - $FurthestBottomRight[0][0]) / 4) + $FurthestBottomRight[0][0]
					$DropY = Round(($FurthestBottomRight[4][1] - $FurthestBottomRight[0][1]) / 4) + $FurthestBottomRight[0][1]
				Case 8
					$m = (537 - 238) / (535 - 128)
					$m2 = (9 - 314) / (430 - 28)
					$b = $THy - ($m * $THx)
					$b2 = 612 - ($m2 * 440)
					$DropX = ($b - $b2) / ($m2 - $m)
					$DropY = Round($m2 * $DropX + $b2)
				Case 9
					$DropX = $FurthestBottomRight[4][0]
					$DropY = $FurthestBottomRight[4][1]
			EndSwitch
			Standard_dropCC($DropX, $DropY, $CC, $AttackMethod, $AimTH)
			If _Sleep(100) Then Return
			If Not $mixedMode Then
				Standard_dropHeroes($DropX, $DropY, $King, $Queen, $AttackMethod, $AimTH)
				$hHeroTimer = TimerInit()
			EndIf
		Else
			If $nbSides = 1 Then
				Standard_dropCC($BottomRight[3][0], $BottomRight[3][1], $CC, $AttackMethod)
			Else
				Standard_dropCC($TopLeft[3][0], $TopLeft[3][1], $CC, $AttackMethod)
			EndIf
			If _Sleep(100) Then Return
			If Not $mixedMode Then
				If $nbSides = 1 Then
					Standard_dropHeroes($BottomRight[3][0], $BottomRight[3][1], $King, $Queen, $AttackMethod)
					$hHeroTimer = TimerInit()
				Else
					Standard_dropHeroes($TopLeft[3][0], $TopLeft[3][1], $King, $Queen, $AttackMethod)
					$hHeroTimer = TimerInit()
				EndIf
			EndIf
		EndIf

		If $mixedMode Then
			If Standard_LaunchTroop($eValkyrie, 1, 1, 1, 1, ($OuterQuad And $attackTH = 2)) Then
				If _Sleep(Standard_SetSleep(1)) Then Return
			EndIf
			If Standard_LaunchTroop($eArcher, 1, 2, 2, 0, ($OuterQuad And $attackTH = 2)) Then
				If _Sleep(Standard_SetSleep(1)) Then Return
			EndIf
			If Standard_LaunchTroop($eGoblin, 1, 2, 2, 0, ($OuterQuad And $attackTH = 2)) Then
				If _Sleep(Standard_SetSleep(1)) Then Return
			EndIf
			If Standard_LaunchTroop($eMinion, 1, 1, 1, 0, ($OuterQuad And $attackTH = 2)) Then
				If _Sleep(Standard_SetSleep(1)) Then Return
			EndIf
			If _Sleep(100) Then Return
			If ($OuterQuad And $attackTH = 2) Then
				Standard_dropHeroes($DropX, $DropY, $King, $Queen, $AttackMethod, $AimTH)
				$hHeroTimer = TimerInit()
			Else
				Standard_dropHeroes($BottomRight[3][0], $BottomRight[3][1], $King, $Queen, $AttackMethod)
				$hHeroTimer = TimerInit()
			EndIf
			If Standard_LaunchTroop($eWallbreaker, 1, 3, 3, 1) Then
				If _Sleep(Standard_SetSleep(1), False) Then Return
			EndIf
		EndIf

		; Check resources
		$Resources = GetResources(True)
		; Nuke DE if desired
		If ($SpellQty >= GUICtrlRead($txtSpellNumber)) And Number($Resources[4]) >= Number(GUICtrlRead($txtDENukeLimit)) And IsChecked($chkNukeAttacking) Then
			SetLog("~Nuking the dark elixir storage", $COLOR_BLUE)
			Standard_DropNukes()
		EndIf

		If _Sleep(Standard_SetSleep(1)) Then Return

		If _Sleep(100) Then Return
		SetLog("~Dropping left over troops", $COLOR_BLUE)
		For $x = 0 To 1
			Standard_PrepareAttack(True) ;Check remaining quantities
			For $i = $eBarbarian To $eMinion ; lauch all remaining troops
				If $i = $eBarbarian Or $i = $eArcher Or $i = $eMinion Or $i = $eHog Or $i = $eValkyrie Then
					Standard_LaunchTroop($i, (($mixedMode) ? 1 : $nbSides), 0, 1)
				Else
					If $i <> $eLSpell Then Standard_LaunchTroop($i, $nbSides, 0, 1, 2)
				EndIf
				If _Sleep(500) Then Return
			Next
		Next

		;Activate KQ's power if deployed
		Local $QueenUsed = ($AttackMethod = 0) ? (IsChecked($chkDeadUseQueen) ? (True) : (False)) : (IsChecked($chkUseQueen) ? (True) : (False))
		Local $KingUsed = ($AttackMethod = 0) ? (IsChecked($chkDeadUseKing) ? (True) : (False)) : (IsChecked($chkUseKing) ? (True) : (False))
		If $KingUsed Or $QueenUsed Then
			If Number(GUICtrlRead($txtKingSkill)) < Number(GUICtrlRead($txtQueenSkill)) Then
				If $King <> -1 Then
					While True
						If (TimerDiff($hHeroTimer) / 1000) > Number(GUICtrlRead($txtKingSkill)) Then
							SetLog("Activate King's power", $COLOR_BLUE)
							SelectDropTroupe($King)
							ExitLoop
						EndIf
						_Sleep(50)
					WEnd
				EndIf
				_Sleep(100)
				If $Queen <> -1 Then
					While True
						If (TimerDiff($hHeroTimer) / 1000) > Number(GUICtrlRead($txtQueenSkill)) Then
							SetLog("Activate Queen's power", $COLOR_BLUE)
							SelectDropTroupe($Queen)
							ExitLoop
						EndIf
						_Sleep(50)
					WEnd
				EndIf
			Else
				If $Queen <> -1 Then
					While True
						If (TimerDiff($hHeroTimer) / 1000) > Number(GUICtrlRead($txtQueenSkill)) Then
							SetLog("Activate Queen's power", $COLOR_BLUE)
							SelectDropTroupe($Queen)
							ExitLoop
						EndIf
						_Sleep(50)
					WEnd
				EndIf
				_Sleep(100)
				If $King <> -1 Then
					While True
						If (TimerDiff($hHeroTimer) / 1000) > Number(GUICtrlRead($txtKingSkill)) Then
							SetLog("Activate King's power", $COLOR_BLUE)
							SelectDropTroupe($King)
							ExitLoop
						EndIf
						_Sleep(50)
					WEnd
				EndIf
			EndIf
		EndIf

		SetLog("~Finished attacking, waiting to finish", $COLOR_GREEN)
	EndIf

	If $TakeAttackSnapShot = 1 Then
		$AttackFile = @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC & "-TH-" & $THLoc & ((($THquadrant > 0) And ($THquadrant < 10)) ? ("-Q" & $THquadrant) : ("")) & (($AttackMethod = 0) ? ("-Dead-") : ("-Live")) & ".jpg"
		_GDIPlus_ImageSaveToFile($hAttackBitmap, $dirAttack & $AttackFile)
		If _Sleep(2000) Then Return
		If $PushBulletEnabled = 1 And $PushBulletattacktype = 1 Then
			_PushFile($AttackFile, "Attacks", "image/jpeg", "Last Raid", $AttackFile)
		EndIf
	EndIf
	_GDIPlus_ImageDispose($hAttackBitmap)
EndFunc   ;==>Standard_Attack

Func Standard_DropNukes()
	;No need to check dark storage again, already checked during search
	;If checkDarkElix() Then
		$nLSpell = -1
		$nSpellQty = 0
		For $i = 0 To 8
			If $atkTroops[$i][0] = $eLSpell Then
				$nLSpell = $i
				$nSpellQty = $atkTroops[$i][1]
			EndIf
		Next
		If $nLSpell = -1 Then
			SetLog("No spell available!", $COLOR_RED)
		Else
			SelectDropTroupe($nLSpell)
			If _Sleep(1000) Then Return
			$z = 0
			Do
				Click(Round(_Random_Gaussian($DEx, 2)), Round(_Random_Gaussian($DEy - 5, 2)))
				_GDIPlus_GraphicsDrawEllipse($Buffer, Round(_Random_Gaussian($DEx, 2)) - 2, Round(_Random_Gaussian($DEy - 5, 2)) - 2, 4, 4, $pLightning)
				If _Sleep(200) Then Return
				$nSpellQty = ReadTroopQuantity($nLSpell)
				$z = $z + 1
			Until $nSpellQty = 0 Or $z = 100
		EndIf
	;EndIf
EndFunc   ;==>Standard_DropNukes

;Drops Clan Castle troops, given the slot and x, y coordinates.

Func Standard_dropCC($x, $y, $slot, $AttackMethod = 1, $CenterLoc = 1) ;Drop clan castle
	Local $useCastle = ($AttackMethod = 0) ? (IsChecked($chkDeadUseClanCastle) ? (1) : (0)) : (IsChecked($chkUseClanCastle) ? (1) : (0))
	If $slot <> -1 And $useCastle = 1 Then
		SetLog("Dropping Clan Castle", $COLOR_BLUE)
		Click(68 + (72 * $slot), 595)
		If _Sleep(500) Then Return
		Click($x, $y, 1, 500, $CenterLoc, 30)
		_GDIPlus_GraphicsDrawEllipse($Buffer, $x - 4, $y - 4, 8, 8, $pCC)
	EndIf
EndFunc   ;==>Standard_dropCC

;Will drop heroes in a specific coordinates, only if slot is not -1
;Only drops when option is clicked.

Func Standard_dropHeroes($x, $y, $KingSlot = -1, $QueenSlot = -1, $AttackMethod = 1, $CenterLoc = 1) ;Drops for king and queen
	While 1
		If _Sleep(2000) Then ExitLoop

		Local $useKing = ($AttackMethod = 0) ? (IsChecked($chkDeadUseKing) ? (1) : (0)) : (IsChecked($chkUseKing) ? (1) : (0))
		Local $useQueen = ($AttackMethod = 0) ? (IsChecked($chkDeadUseQueen) ? (1) : (0)) : (IsChecked($chkUseQueen) ? (1) : (0))

		If $KingSlot <> -1 And $useKing = 1 Then
			SetLog("Dropping King", $COLOR_BLUE)
			Click(68 + (72 * $KingSlot), 595) ;Select King
			If _Sleep(500) Then Return
			Click($x, $y, 1, 0, $CenterLoc, 30)
			_GDIPlus_GraphicsDrawEllipse($Buffer, $x - 6, $y - 6, 12, 12, $pKing)
			$checkKPower = True
		EndIf

		If _Sleep(1000) Then ExitLoop

		If $QueenSlot <> -1 And $useQueen = 1 Then
			SetLog("Dropping Queen", $COLOR_BLUE)
			Click(68 + (72 * $QueenSlot), 595) ;Select Queen
			If _Sleep(500) Then Return
			Click($x, $y, 1, 0, $CenterLoc, 30)
			_GDIPlus_GraphicsDrawEllipse($Buffer, $x - 5, $y - 5, 10, 10, $pQueen)
			$checkQPower = True
		EndIf

		ExitLoop
	WEnd
EndFunc   ;==>Standard_dropHeroes
