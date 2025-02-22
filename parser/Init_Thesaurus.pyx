from libc.stdio cimport fopen,fclose,fwrite,FILE,fread
from libc.stdlib cimport malloc,free

DEF STEP=20


cdef struct HI: 
    int left    #左侧范围
    int right   #右侧范围


###################### init_hashIndex  from  Thesaurus.pyx  #################

cdef class init_hashIndex:
    '''
    init he hash index
    '''
    #define the hash index 

    cdef HI hi[STEP]

    def __cinit__(self,char *ph):
        '''
        init
        '''
        cdef FILE *fp=<FILE *>fopen(ph,"rb")
        fread(self.hi,sizeof(HI),STEP,fp)
        fclose(fp)

    def pos(self,double hashvalue):
        '''
        pos the word by hashvalue 
        if the word is beyond hash return -1
        else return the pos
        
        '''
        cdef int cur=-1
        
        if hashvalue>self.hi[0].left:
            cur+=1
        else:
            return cur

        while hashvalue > self.hi[cur].left:

            cur+=1

        return cur

####################################################################


#定义 hashIndex 结构
cdef struct HI: #hashIndex 结构
    int left    #左侧范围
    int right   #右侧范围
    

cdef class Init_thesaurus:
    '''
    初始化词库
    '''
    #使用动态分配内存方式  
    #分配词库内存空间
    cdef char **word_list
    #一级hash 参考表 初始化
    cdef init_hashIndex hashIndex
    #词库长度 由 delloc 调用
    cdef int length

    def __cinit__(self,char *ph):
        '''
        传入词库地址
        初始化词库
        '''
        #一级hash 参考表 初始化
        self.hashIndex = init_hashIndex("sore/hashIndex.b")

        cdef:
            int i
            int l

        f=open(ph)
        words=f.read()
        f.close()

        #词的数量 
        self.length=len(words)
        cdef char  **li=<char **>malloc( sizeof(char *) * self.length )
        if li!=NULL:
            print 'the li is successful'
            self.word_list=li
        else:
            print 'the li is failed'

        #开始对每个词分配内存 
        #并且分配内存
        for i,w in enumerate(words):
            self.word_list[i]=<char *>malloc( sizeof(char) * len(w) )
            self.word_list[i]=w

    def __dealloc__(self):
        '''
        释放c内存空间
        '''
        print 'begin to delete all the C spaces'

        cdef char* point
        cdef int i=0

        #释放每一个词的空间
        for i in range(self.length):
            free(self.word_list[i])

        #释放整个词库 pointer 的空间
        free(self.word_list)


    cdef double v(self,data):
        '''
        将元素比较的属性取出
        '''
        return hash(data)

    def show(self):
        for d in self.wlist:
            print hash(d),d

    def find(self,data):
        '''
        具体查取值 
        若存在 返回位置 
        若不存在 返回   0
        '''
        #需要测试 
        #print 'want to find ',hash(data),data
        cdef:
            int l
            int fir
            int mid
            int end
            int pos
            HI cur  #范围

        dv=self.v(data)     #传入词的hash

        pos=self.hashIndex( dv )

        if pos!=-1 and pos<STEP:
            cur=self.hashIndex.hi[pos]

        else:
            print "the word is not in wordbar or pos wrong"
            return False

        #取得 hash 的一级推荐范围
        fir=cur.left
        end=cur.right
        mid=fir

        while fir<end:
            mid=(fir+ end)/2
            if ( dv > self.v(self.wlist[mid]) ):
                fir = mid + 1
            elif  dv < self.v(self.wlist[mid]) :
                end = mid - 1
            else:
                break

        if fir == end:
            if self.v(self.wlist[fir]) > dv:
                return 0 
            elif self.v(self.wlist[fir]) < dv:
                return 0
            else:
                #print 'return fir,mid,end',fir,mid,end
                return end#需要测试
                
        elif fir>end:
            return 0

        else:
            #print '1return fir,mid,end',fir,mid,end
            return mid#需要测试



        








