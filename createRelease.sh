ALL_RESULTS=build/allResults.json

[ -d build ] || mkdir build
[ -d data/release ] || mkdir -p data/release

aws --profile election-test s3 sync s3://odileeds-uk-election-2019/processed/live data/live/

cat data/live/?????????.json | jq --slurp '.' > $ALL_RESULTS

jq --raw-output '
  [ "const_id","const_name","candidate_id","candidate_name","party_code","votes","pct_share","pct_point_change_from_ge17" ] as $cols
  | [
    .[]
    | .id as $conId
    | .title as $conName
    | .elections["2019-12-12"].candidates[]
    | [ $conId, $conName, .id, .name, .party.code, .party.title, .votes, .share, .change ]
    ] as $rows
  | $cols, $rows[] | @csv
' $ALL_RESULTS > data/ge_2019_candidates.csv

jq --raw-output '
  [
    "const_id",
    "const_name",
    "elected_mp_party",
    "elected_mp_party_name",
    "elected_mp_name",
    "elected_mp_votes",
    "majority",
    "valid",
    "invalid",
    "electorate",
    "turnout_pct",
    "ge17_party",
    "ge17_majority",
    "ge17_turnout" ] as $cols
  | [
    .[]
    | .id as $conId
    | .title as $conName
    | .elections["2017-06-08"] as $ge2017
    | .elections["2019-12-12"]
    | .mp as $mpName
    | [
        $conId,
        $conName,
        .party.code,
        .party.title,
        .mp,
        (.candidates[] | select( .name == $mpName ) | .votes ),
        .majority,
        .valid,
        .invalid,
        .electorate,
        .turnout.pc,
        $ge2017.party.code,
        $ge2017.majority,
        $ge2017.turnout.pc
      ]
    ] as $rows
  | $cols, $rows[] | @csv
' $ALL_RESULTS > data/ge_2019_constituencies.csv