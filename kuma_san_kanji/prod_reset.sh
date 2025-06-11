#!/bin/bash
echo "Starting production database reset..."
/app/bin/kuma_san_kanji eval 'Mix.Task.run("ash.reset", ["--yes"])'
echo "Reset completed"
