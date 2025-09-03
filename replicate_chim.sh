import os
import datetime
import pandas as pd
import re
from io import StringIO
import shutil

tmp = "/gpfs/home/chh20csu/scratch/ChimeraTE_output/TUK_TUK.fasta/tmp"

# Get current time string (replacing the time() function)
x = datetime.datetime.now()
clock = "[" + x.strftime("%A") + " " + str(x.day) + "/" + str(x.month) + "/" + str(x.year) + " - " + x.strftime("%H") + "h:" + x.strftime("%M") + "]"

input = pd.read_csv("/gpfs/home/chh20csu/CorydoradinaeVenom2025/chimeraTE_input/TUK_TUK.fasta_fq.tsv", 
                       header=None, sep="\t", usecols=[0,1,2], names=['mate1', 'mate2', 'group'])

replicate = 2
coverage = 2
tables = ["_chimreads_evidence.tsv"]

print(f"{clock}\tSearching for chimeric transcripts found in at least {replicate} replicates\n")

for chim_type in tables:
    df_store = pd.DataFrame()
    for file in os.listdir(tmp):
        if file.endswith(chim_type):
            table = os.path.join(tmp, file)
            if os.path.exists(table) and os.stat(table).st_size > 0:
                data = pd.read_csv(table, sep='\t', header=None)
                df_store = df_store.append(data, ignore_index=True)
    
    if df_store is not None and not df_store.empty:
        if chim_type == "_chimreads_evidence.tsv":
            tab = df_store.iloc[:, [0,1]].to_csv(header=False, index=False, sep='&')
            tab = StringIO(tab)
            tab = pd.read_table(tab, sep='\t', header=None).value_counts().rename_axis('chimeras').reset_index(name='counts').query('counts == @replicate').iloc[:,0].to_csv(sep='&', header=None, index=False)
            tab = re.sub('&', '\t', tab)
            tab = re.sub('"', '', tab)
            tab = StringIO(tab)
            recurrent_geneID_teID = pd.read_csv(tab, header=None, sep='\t', usecols=[0,1], names=['gene_id', 'TE_id'])
            for row in recurrent_geneID_teID.itertuples():
                merged = None
                geneID = row[1]
                teID = row[2]
                for file in os.listdir(tmp):
                    if file.endswith(chim_type):
                        raw_result = pd.read_csv(os.path.join(tmp, file), header=None, sep='\t', usecols=[0,1,2,3,4],
                                    names=['gene_id', 'TE_fam', 'cov', 'transcripts', 'fpkm'])
                        match = raw_result.query('gene_id == @geneID').query('TE_fam == @teID')
                        if merged is None:
                            merged = match
                        else:
                            merged = merged.append(match, ignore_index=True)
                if merged is not None:
                    mean_cov = merged["cov"].mean()
                    if int(mean_cov) >= int(coverage):
                        mean_fpkm = merged["fpkm"].mean()
                        transcript_IDs = merged['transcripts'].to_csv(header=None, sep='\t', index=False)
                        transcript_IDs = re.sub('; ', '\n', transcript_IDs)
                        transcript_IDs = transcript_IDs.rstrip('\n').split('\n')
                        nodup_IDs = []
                        for ID in transcript_IDs:
                            if ID not in nodup_IDs:
                                nodup_IDs.append(ID)
                        transcripts_nodup = '; '.join(nodup_IDs)
                        
                        with open(os.path.join(tmp, 'chimreads_replicated.tsv'), "a") as output:
                            print(f"{geneID}\t{teID}\t{mean_cov}\t{transcripts_nodup}\t{mean_fpkm}", file=output)
