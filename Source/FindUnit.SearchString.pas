unit FindUnit.SearchString;

interface

uses
  Classes, FindUnit.Parser, Generics.Collections, FindUnit.Header;

type
  TSearchString = class(TObject)
  protected
    FCandidates: TObjectList<TFindUnitItem>;

    function FoundAllEntries(Entries: TStringList; Text: string): Boolean;

    function GetMatcherOnItemListType(Item: TFindUnitItem; SearchString: TStringList; List: TStringList; const Sufix: string; var ItensFound: integer): string;
    function GetMatchesOnItem(Item: TFindUnitItem; SearchString: TStringList; var ItensFound: integer): string;
  public
    constructor Create(Candidates: TObjectList<TFindUnitItem>);
    destructor Destroy; override;
    function GetMatch(SearchString: string): TStringList;
  end;

implementation

uses
  SysUtils;

{ TSearchString }

constructor TSearchString.Create(Candidates: TObjectList<TFindUnitItem>);
begin
  FCandidates := Candidates;
end;

destructor TSearchString.Destroy;
begin
  inherited;
end;

function TSearchString.FoundAllEntries(Entries: TStringList; Text: string): Boolean;
var
  I: Integer;
  Entry: string;
begin
  Result := True;
  for I := 0 to Entries.Count -1 do
  begin
    Entry := Entries[i];
    Result := Pos(Entry, Text) <> 0;
    if not Result then
      Exit;
  end;
end;

function TSearchString.GetMatch(SearchString: string): TStringList;
var
  I: Integer;
  Item: TFindUnitItem;
  ItensFound: Integer;
  SearchList: TStringList;
begin
  ItensFound := 0;
  Result := TStringList.Create;

  SearchList := TStringList.Create;
  try
    SearchList.Delimiter := ' ';
    SearchList.DelimitedText := UpperCase(SearchString);

    for I := 0 to FCandidates.Count - 1 do
    begin
      Item := FCandidates[I];

      if FoundAllEntries(SearchList, UpperCase(Item.OriginUnitName) + '.') then
      begin
        Result.Text := Result.Text + Item.OriginUnitName + '.* - Unit';
        Inc(ItensFound);
      end;

      Result.Text := Result.Text + GetMatchesOnItem(Item, SearchList, ItensFound);
      if ItensFound >= MAX_RETURN_ITEMS then
        Exit;
    end;
  finally
    SearchList.Free;
  end;
end;

function TSearchString.GetMatcherOnItemListType(Item: TFindUnitItem; SearchString: TStringList; List: TStringList; const Sufix: string; var ItensFound: integer): string;
var
  LocalSearchUpperCase: TStringList;
  iString: Integer;
  ItemToFind: string;
  MatchList: TStringList;
  FoundAll: Boolean;
begin
  MatchList := TStringList.Create;
  LocalSearchUpperCase := TStringList.Create;
  try
    LocalSearchUpperCase.Text := UpperCase(List.Text);

    for iString := 0 to LocalSearchUpperCase.Count - 1 do
    begin
      ItemToFind :=  UpperCase(Item.OriginUnitName) + '.' + LocalSearchUpperCase[iString];

      if FoundAllEntries(SearchString, ItemToFind) then
      begin
        MatchList.Add(Item.OriginUnitName + '.' + List[iString] + Sufix);
        Inc(ItensFound);
        if ItensFound > MAX_RETURN_ITEMS then
          Exit;
      end;
    end;
  finally
    Result := MatchList.Text;
    MatchList.Free;
    LocalSearchUpperCase.Free;
  end;
end;

function TSearchString.GetMatchesOnItem(Item: TFindUnitItem; SearchString: TStringList; var ItensFound: integer): string;
var
  ListType: TListType;
  List: TStringList;
  I: TListType;
begin
  Result := '';
  for ListType := Low(TListType) to High(TListType) do
  begin
    List := Item.GetListFromType(ListType);
    Result := Result + GetMatcherOnItemListType(Item, SearchString, List, strListTypeDescription[ListType], ItensFound);
    if ItensFound >= MAX_RETURN_ITEMS then
      Exit;
  end;
end;



end.

