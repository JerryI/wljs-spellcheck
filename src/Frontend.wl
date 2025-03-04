BeginPackage["CoffeeLiqueur`Extensions`Spellcheck`", {
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`",
    "JerryI`Misc`WLJS`Transport`",
    "CoffeeLiqueur`Extensions`FrontendObject`"
}]

Begin["`Internal`"]

Needs["CoffeeLiqueur`Notebook`Cells`" -> "cell`"];
Needs["CoffeeLiqueur`Notebook`AppExtensions`" -> "AppExtensions`"];

EventHandler["spellcheck-extension", {"Check" -> Function[data,
    With[{
        text = cell`HashMap[data[[2]]]["Data"],
        ranges = data[[1]]
    },
        MapThread[Function[{part, fromTo}, processString[sanitize[part], fromTo[[1]]] ], {StringTake[text, ranges], ranges}] // Flatten
    ]
]}];

sanitize[text_] := StringReplace[text, (s:("$"~~(Except["$"]..)~~"$")) :> FromCharacterCode[Table[48, {StringLength[s]}] ] ]

processString[text_, offset_] :=
    With[{
        match = StringCases[text, (s:(StartOfString~~"."~~(WordCharacter..)~~"\n")) :> s]
    },
        If[Length[match] == 0,
            check[text, offset]
        ,
            {}
        ]
    ]

check[text_, offset_] := With[{words = TextPosition[text, "Word"]},
  Map[Function[w, spellCheck[StringTake[text, w], w, offset] ], words]
] // Flatten

spellCheck[word_, {f_, t_}, offset_] := With[{
  list = SpellingCorrectionList[word]
},
  If[Length[list] == 0, Return[{}] ];
  If[First[list] == word, Return[{}] ];
  
  <|"from"->(f+offset), "to"->(t+offset), "item"->Take[list, Min[3, Length[list] ] ]|>
]

End[]
EndPackage[]