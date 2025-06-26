#!/bin/bash

backup_dir="/home/N1nE/Temp/obsdbbk"
source_file="/home/N1nE/Temp/obsdb"
date=$(date +"%Y%m%d")

# Daily backup
daily_file="${backup_dir}/obsdb${date}Dayly_bk"
cp -r "$source_file" "$daily_file"
find "$backup_dir" -name "obsdb*Dayly_bk" | sort | head -n -3 | xargs rm -f

# Weekly backup (every 7 days)
if [[ $(date +%u) -eq 7 ]]; then
  weekly_file="${backup_dir}/obsdb${date}weekly_bk"
  cp -r "$source_file" "$weekly_file"
  find "$backup_dir" -name "obsdb*weekly_bk" | sort | head -n -2 | xargs rm -f
fi

# Monthly backup (every first day of the month)
if [[ $(date +%d) -eq 1 ]]; then
  monthly_file="${backup_dir}/obsdb${date}monthly_bk"
  cp -r "$source_file" "$monthly_file"
  find "$backup_dir" -name "obsdb*monthly_bk" | sort | head -n -1 | xargs rm -f
fi
