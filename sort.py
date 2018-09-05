#file = ('sadas asdfge fddgr asda')
file1 = open('1.txt', 'r')
file = file1.read()
#print(file)
newList = list(file)
#newList = file.list()
newList.sort()
#so = newList
#print so
print newList
file2 = open('2.txt', 'w')
str2 = ''.join(newList)
file2.write(str2)
