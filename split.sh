#!/bin/bash
dir=$(pwd)
echo "========>>> SPLIT-MIUI"
if [[ -f "$(ls *.zip 2>/dev/null)" ]]; then
	zipname=$(ls *.zip)
	echo "$zipname detect"
else echo "Not Found Any ROom"
fi 
mkdir zip_temp
cp $zipname zip_temp
cd zip_temp
echo "Extract $zipname"
jar xf $zipname
rm $zipname
cd ..
echo "========>>> Make sub-file"
echo "Move System to sub_folder"
cp -R template sub_folder
cd zip_temp 
mv system.* $dir/sub_folder
cd ..
echo "========>>> Correct devices info"
cd zip_temp
sys_size=$(awk -F"resize system " '/resize system /{print $2}' dynamic_partitions_op_list | head -1)
echo "System size : $sys_size"
sed -i "s|sys_size|$sys_size|g" $dir/sub_folder/dynamic_partitions_op_list
cd ..
echo "========>>> Remove system in $zipname"
cd zip_temp
rm_sys=$(grep -n "system" META-INF/com/google/android/updater-script | grep -Eo '^[^:]+' | head -4)
set -- $rm_sys
for i; do out="$i${out:+ }$out"; done
echo "$out"

echo
echo $out
for i in $out ; do
	sed -i "${i}d" META-INF/com/google/android/updater-script
done
cd ..
echo "========>>> Packing into 2 file "
cd zip_temp/
7za a -tzip "$dir/1_$zipname" * 
cd $dir/sub_folder/
7za a -tzip "$dir/2_$zipname" * 