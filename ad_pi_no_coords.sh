#!/bin/bash
# 2017Oct29 modification to print out ad values for all samples with 2 columns
# for each sample giving the ad at each allele
# change to see which field AD is in to accommodate various VCF formats
# presumption is that AD is in same place everywhere as it is in record 1
#
# also original version had an error for this data "./.:.:1" e.g from scaffold12 snp 756
# where using [3] and [4] had it reporting 1 instead of -1
#
# first awk will inject a single number as first line of input to second awk and for other lines
# will perform the equivalent of cut -f1,2,10-
#
# reason we change technique is so we use stdin to pipe in the file

#ad_pos=$(head -1 $1|awk '{if(split($9,a,":")>1){for(i=1;i<=length(a);i++){if(a[i]=="AD")ad_ix=i}}else if($9=="AD")ad_ix=1;}END{print ad_ix}')
#cut -f1,2,10- $1 | \
vcf_input=$1
awk 'BEGIN{OFS="\t"}
     NR==1{if(split($9,a,":")>1){for(i=1;i<=length(a);i++){if(a[i]=="AD")ad_ix=i}}else if($9=="AD")ad_ix=1; print ad_ix}
     {printf "%s\t%s", $1,$2; for(f=10;f<=NF;f++)printf "\t%s", $f; printf "\n" }' $vcf_input | \
  awk -v AD_pos=$ad_pos \
       'NR==1{if(NF==1 && $1 > 0){AD_pos=$1};
              if(AD_pos){m="AD in subfield "AD_pos" of field 9"}else{m="AD subfield not found in field 9"}; print m > "/dev/stderr";
              if(!AD_pos)exit; if(NF==1)next;
       }
       {for(f=3; f<=NF; f++) {
           ad1 = 0; ad2 = 0;
           if(split($f,a,":") >= AD_pos) {
              if (split(a[AD_pos],ad,",")==2) {
                ad1=ad[1]; ad2=ad[2]
              }
           }
           printf "%s\t%s\t", ad1, ad2
         }
         printf "\n"
       }'

exit 0
