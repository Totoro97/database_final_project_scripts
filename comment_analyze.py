import pandas as pd
import numpy as np

data = pd.read_csv('../data/comment.csv')
lis = ['dt', 'sku_id', 'comment_num', 'has_bad_comment', 'bad_comment_rate']

n = len(lis)
vis = np.zeros((1 << n, n), dtype = np.int32)
out_str = ''
for A in range(1 << n) :
	for B in range(n) :		
		st = A
		flag = False
		while st > 0 : 
			if vis[st][B] == 1 :
				flag = True
				break
			st = (st - 1) & A
		if flag :
			continue
		a = []
		b = [lis[B]]
		for i in range(n) :
			if ((A >> i) & 1) == 1 :
				a.append(lis[i])
		rela = {}
		flag = True
		for row_ in data.iterrows() :
			row = row_[1]
			x = ''
			y = ''
			for a_ in a :
				x += str(row[a_])
			for b_ in b :
				y += str(row[b_])
			if x not in rela :
				rela[x] = y
			elif rela[x] != y :
				flag = False
				break
		if flag :
			print(str(a) + '->' + str(b))
			out_str += str(a) + '->' + str(b) + '\n'
			vis[A][B] = 1

out_file = open('comment_analyze.out', 'w')
out_file.write(out_str)
out_file.close()