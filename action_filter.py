import pandas as pd
import random

data = pd.read_csv('../data/action.csv')
out_str = ''
cnt = 0

for row_ in data.iterrows() :
	#print(row_[1])
	if random.randint(0, 200) == 1 : 
		flag = False
		print(cnt)
		cnt += 1
		for dt in row_[1] :
			if flag :
				out_str += ','
			flag = True
			out_str += str(dt)
		out_str += '\n'

out_file = open('../data/action_random.csv', 'w')
out_file.write(out_str)
out_file.close()