file = torch.DiskFile(opt.binfilename,'r')
local max_w = 50

function readStringv2(file)  
	local str = {}
	for i = 1,max_w do
		local char = file:readChar()
		
		if char == 32 or char == 10 or char == 0 then
			break
		else
			str[#str+1] = char
		end
	end
	str = torch.CharStorage(str)
	return str:string()
end

--Reading Header
file:ascii()
num_words = file:readInt()
embedding_size = file:readInt()

local w2vvocab = {}
local v2wvocab = {}
local M = torch.FloatTensor(words, size)

--Reading Contents
file:binary()
for i = 1, num_words do
	local word = readStringv2(file)
	local word_embedding = file:readFloat(embedding_size)
	word_embedding = torch.FloatTensor(word_embedding)
	local norm = torch.norm(word_embedding, 2)
	if norm ~= 0 then word_embedding:div(norm) end
	w2vvocab[word] = i
	v2wvocab[i] = word
	M[{{i},{}}] = word_embedding
end

--Writing Files
word2vec = {}
word2vec.M = M
word2vec.w2vvocab = w2vvocab
word2vec.v2wvocab = v2wvocab
torch.save(opt.outfilename,word2vec)
print('Writing t7 File for future usage.')

return word2vec


