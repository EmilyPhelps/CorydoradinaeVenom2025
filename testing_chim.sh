import datetime
import subprocess
import glob, os
import pandas as pd
import re
import csv
from io import StringIO
from __main__ import *

tmp = "/projects/SIM_SIM.fasta/tmp"

def time():
    x = datetime.datetime.now()
    clock = str("[" + str(x.strftime("%A")) + " " + str(x.day) + "/" + str(x.month) +  "/" + str(x.year) + " - " + str(x.strftime("%H")) + "h:" + str(x.strftime("%M")) + "]")
    return clock


def chim_reads_rep():
    #from __main__ import tmp
    #from __main__ import time

    replicate = str(args.replicate)
    coverage = str(args.coverage)
    tables = ["_chimreads_evidence.tsv", "_transcriptome_evidence.tsv"]

    clock = time()
    print(str(clock) + '\t' + "Searching for chimeric transcripts found in at least " + str(replicate) + " replicates" + '\n' )

    for chim_type in tables:
        df_store=pd.DataFrame()

        for file in os.listdir(str(tmp)):
            if file.endswith(str(chim_type)):
                table = str(tmp + '/' + file)
                if os.path.exists(table) == True:
                    if os.stat(str(table)).st_size > 0:
                        data = pd.read_csv(str(tmp + "/" + file), sep = '\t', header = None)
                        df_store=df_store.append(data, ignore_index=True)
        if df_store is not None and not df_store.empty:
            if chim_type == "_chimreads_evidence.tsv":
                tab = df_store.iloc[:,[0,1]].to_csv(header=False, index=False, sep='&')
                tab = StringIO(tab)
                tab = pd.read_table(tab, sep = '\t', header = None).value_counts().rename_axis('chimeras').reset_index(name='counts').query('counts == @replicate').iloc[:,0].to_csv(sep='&', header=None, index=False)
                tab = re.sub('&', '\t', tab); tab = re.sub('"', '', tab); tab = StringIO(tab)
                recurrent_geneID_teID = pd.read_csv(tab, header=None, sep='\t', usecols=[0,1], names=['gene_id', 'TE_id'])

                for row in recurrent_geneID_teID.itertuples():
                    merged = None
                    geneID = row[1]
                    teID = row[2]

                    for file in os.listdir(str(tmp)):
                        if file.endswith(str(chim_type)):
                            raw_result = pd.read_csv(str(tmp + '/' + file), header=None, sep='\t', usecols=[0,1,2,3,4],names=['gene_id', 'TE_fam', 'cov', 'transcripts','fpkm'])
                            match = raw_result.query('gene_id == @geneID').query('TE_fam == @teID')
                            if merged is None:
                                merged = match
                            else:
                                merged = merged.append(match, ignore_index=True)
                    if merged is not None:
                        mean_cov = merged["cov"].mean()
                        if int(mean_cov) >= int(coverage):
                            mean_fpkm = merged["fpkm"].mean()

                            transcript_IDs = merged['transcripts'].to_csv(header=None, sep='\t', index = False)
                            transcript_IDs = re.sub('; ', '\n', transcript_IDs)
                            transcript_IDs = transcript_IDs.rstrip('\n').split('\n')
                            nodup_IDs = []
                            for ID in transcript_IDs:
                                if ID not in nodup_IDs:
                                    nodup_IDs.append(ID)
                            transcripts_nodup = '; '.join(nodup_IDs)
                            with open(str(tmp + '/chimreads_replicated.tsv'), "a") as output:
                                print(str(geneID) + '\t' + str(teID) + '\t' + str(mean_cov) + '\t' + str(transcripts_nodup) + '\t' + str(mean_fpkm), file=output)
                            output.close()
                if not args.assembly:
                    if check_file(str(tmp + '/chimreads_replicated.tsv')) == True:
                        copy(str(tmp + '/chimreads_replicated.tsv'), out_dir)

            else:
                tab = df_store.iloc[:,[2,7]].to_csv(header=False, index=False, sep='&')
                tab = StringIO(tab)
                tab = pd.read_table(tab, sep = '\t', header = None).value_counts().rename_axis('chimeras').reset_index(name='counts').query('counts == @replicate').iloc[:,0].to_csv(sep='&', header=None, index=False)
                tab = re.sub('&', '\t', tab); tab = re.sub('"', '', tab); tab = StringIO(tab)
                recurrent_geneID_teID = pd.read_csv(tab, header=None, sep='\t', usecols=[0,1], names=['gene_id', 'TE_id'])

                for row in recurrent_geneID_teID.itertuples():
                    merged = None
                    geneID = row[1]
                    teID = row[2]

                    for file in os.listdir(str(tmp)):
                        if file.endswith(str(chim_type)):
                            raw_result = pd.read_csv(str(tmp + '/' + file), header=None, sep='\t', usecols=[0,1,2,3,4,5,6,7,8],names=['trinity_id', 'transcrit_id', 'gene_id', 'identity','trinity_length', 'transcript_length', 'match_length', 'TE_fam', 'cov'])
                            match = raw_result.query('gene_id == @geneID').query('TE_fam == @teID')
                            if merged is None:
                                merged = match
                            else:
                                merged = merged.append(match, ignore_index=True)
                    if merged is not None:
                        mean_cov = merged["cov"].mean()
                        if int(mean_cov) >= int(coverage):
                            mean_id = merged["identity"].mean()
                            mean_trinity_length = merged["trinity_length"].mean()
                            mean_match_length = merged["match_length"].mean()
                            mean_transc_length = merged["transcript_length"].mean()
                            transcript_IDs = merged['transcrit_id'].to_csv(header=None, sep='\t', index = False)
                            transcript_IDs = transcript_IDs.rstrip('\n').split('\n')
                            nodup_IDs = []
                            for ID in transcript_IDs:
                                if ID not in nodup_IDs:
                                    nodup_IDs.append(ID)
                            transcripts_nodup = '; '.join(nodup_IDs)

                            trinity_IDs = merged['trinity_id'].to_csv(header=None, sep='\t', index = False)
                            trinity_IDs = trinity_IDs.rstrip('\n').split('\n')
                            nodup_IDs = []
                            for ID in trinity_IDs:
                                if ID not in nodup_IDs:
                                    nodup_IDs.append(ID)
                            trinity_nodup = '; '.join(nodup_IDs)
                            with open(str(tmp + '/transcriptome_replicated.tsv'), "a") as output:
                                print(str(geneID) + '\t' + str(teID) + '\t' + str(transcripts_nodup) + '\t' + str(trinity_nodup) + '\t' + str(mean_id) + '\t' + str(mean_trinity_length) + '\t' + str(mean_transc_length) +'\t'+ str(mean_match_length) + '\t' + str(mean_cov), file=output)
                            output.close()
