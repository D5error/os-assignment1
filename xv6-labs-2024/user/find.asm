
user/_find:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <find>:
#include "user/user.h"
#include "kernel/fcntl.h"
#include "kernel/stat.h"


void find(char *path, char *filename) {
   0:	d9010113          	addi	sp,sp,-624
   4:	26113423          	sd	ra,616(sp)
   8:	26813023          	sd	s0,608(sp)
   c:	25213823          	sd	s2,592(sp)
  10:	25313423          	sd	s3,584(sp)
  14:	1c80                	addi	s0,sp,624
  16:	892a                	mv	s2,a0
  18:	89ae                	mv	s3,a1
    char buf[512], *p;
    struct dirent de;

    // 访问路径
    int fd;
    if ((fd = open(path, O_RDONLY)) < 0) {
  1a:	4581                	li	a1,0
  1c:	456000ef          	jal	472 <open>
  20:	06054b63          	bltz	a0,96 <find+0x96>
  24:	24913c23          	sd	s1,600(sp)
  28:	84aa                	mv	s1,a0
        return;
    }

    // 获取路径信息
    struct stat st;
    if (fstat(fd, &st) < 0) {
  2a:	d9840593          	addi	a1,s0,-616
  2e:	45c000ef          	jal	48a <fstat>
  32:	06054b63          	bltz	a0,a8 <find+0xa8>
        close(fd);
        return;
    }

    // 在文件夹中查找文件名为filename的文件
    switch(st.type) {
  36:	da041783          	lh	a5,-608(s0)
  3a:	4705                	li	a4,1
  3c:	08e78e63          	beq	a5,a4,d8 <find+0xd8>
  40:	4709                	li	a4,2
  42:	02e79a63          	bne	a5,a4,76 <find+0x76>
  46:	25413023          	sd	s4,576(sp)
        // 文件
        case T_FILE:
            if (strcmp(path + strlen(path) - strlen(filename), filename) == 0) {
  4a:	854a                	mv	a0,s2
  4c:	1d6000ef          	jal	222 <strlen>
  50:	00050a1b          	sext.w	s4,a0
  54:	854e                	mv	a0,s3
  56:	1cc000ef          	jal	222 <strlen>
  5a:	1a02                	slli	s4,s4,0x20
  5c:	020a5a13          	srli	s4,s4,0x20
  60:	1502                	slli	a0,a0,0x20
  62:	9101                	srli	a0,a0,0x20
  64:	40aa0533          	sub	a0,s4,a0
  68:	85ce                	mv	a1,s3
  6a:	954a                	add	a0,a0,s2
  6c:	18a000ef          	jal	1f6 <strcmp>
  70:	c931                	beqz	a0,c4 <find+0xc4>
  72:	24013a03          	ld	s4,576(sp)
                // 递归查询
                find(buf, filename);
            }

    }
    close(fd);
  76:	8526                	mv	a0,s1
  78:	3e2000ef          	jal	45a <close>
  7c:	25813483          	ld	s1,600(sp)
}
  80:	26813083          	ld	ra,616(sp)
  84:	26013403          	ld	s0,608(sp)
  88:	25013903          	ld	s2,592(sp)
  8c:	24813983          	ld	s3,584(sp)
  90:	27010113          	addi	sp,sp,624
  94:	8082                	ret
        fprintf(2, "find: cannot open %s\n", path);
  96:	864a                	mv	a2,s2
  98:	00001597          	auipc	a1,0x1
  9c:	96858593          	addi	a1,a1,-1688 # a00 <malloc+0x102>
  a0:	4509                	li	a0,2
  a2:	77e000ef          	jal	820 <fprintf>
        return;
  a6:	bfe9                	j	80 <find+0x80>
        fprintf(2, "find: cannot stat %s\n", path);
  a8:	864a                	mv	a2,s2
  aa:	00001597          	auipc	a1,0x1
  ae:	97658593          	addi	a1,a1,-1674 # a20 <malloc+0x122>
  b2:	4509                	li	a0,2
  b4:	76c000ef          	jal	820 <fprintf>
        close(fd);
  b8:	8526                	mv	a0,s1
  ba:	3a0000ef          	jal	45a <close>
        return;
  be:	25813483          	ld	s1,600(sp)
  c2:	bf7d                	j	80 <find+0x80>
                printf("%s\n", path);
  c4:	85ca                	mv	a1,s2
  c6:	00001517          	auipc	a0,0x1
  ca:	97250513          	addi	a0,a0,-1678 # a38 <malloc+0x13a>
  ce:	77c000ef          	jal	84a <printf>
  d2:	24013a03          	ld	s4,576(sp)
  d6:	b745                	j	76 <find+0x76>
            if (strlen(path) + 1 + DIRSIZ > sizeof buf) {
  d8:	854a                	mv	a0,s2
  da:	148000ef          	jal	222 <strlen>
  de:	253d                	addiw	a0,a0,15
  e0:	20000793          	li	a5,512
  e4:	00a7f963          	bgeu	a5,a0,f6 <find+0xf6>
                printf("find: path too long\n");
  e8:	00001517          	auipc	a0,0x1
  ec:	95850513          	addi	a0,a0,-1704 # a40 <malloc+0x142>
  f0:	75a000ef          	jal	84a <printf>
                break;                
  f4:	b749                	j	76 <find+0x76>
  f6:	25413023          	sd	s4,576(sp)
  fa:	23513c23          	sd	s5,568(sp)
  fe:	23613823          	sd	s6,560(sp)
            strcpy(buf, path);
 102:	85ca                	mv	a1,s2
 104:	dc040513          	addi	a0,s0,-576
 108:	0d2000ef          	jal	1da <strcpy>
            p = buf + strlen(buf);
 10c:	dc040513          	addi	a0,s0,-576
 110:	112000ef          	jal	222 <strlen>
 114:	1502                	slli	a0,a0,0x20
 116:	9101                	srli	a0,a0,0x20
 118:	dc040793          	addi	a5,s0,-576
 11c:	00a78933          	add	s2,a5,a0
            *p++ = '/';
 120:	00190b13          	addi	s6,s2,1
 124:	02f00793          	li	a5,47
 128:	00f90023          	sb	a5,0(s2)
                if(strcmp(de.name, ".") == 0 || strcmp(de.name, "..") == 0) {
 12c:	00001a17          	auipc	s4,0x1
 130:	92ca0a13          	addi	s4,s4,-1748 # a58 <malloc+0x15a>
 134:	00001a97          	auipc	s5,0x1
 138:	92ca8a93          	addi	s5,s5,-1748 # a60 <malloc+0x162>
            while (read(fd, &de, sizeof(de)) == sizeof(de)) {
 13c:	4641                	li	a2,16
 13e:	db040593          	addi	a1,s0,-592
 142:	8526                	mv	a0,s1
 144:	306000ef          	jal	44a <read>
 148:	47c1                	li	a5,16
 14a:	02f51f63          	bne	a0,a5,188 <find+0x188>
                if (de.inum == 0) {            
 14e:	db045783          	lhu	a5,-592(s0)
 152:	d7ed                	beqz	a5,13c <find+0x13c>
                if(strcmp(de.name, ".") == 0 || strcmp(de.name, "..") == 0) {
 154:	85d2                	mv	a1,s4
 156:	db240513          	addi	a0,s0,-590
 15a:	09c000ef          	jal	1f6 <strcmp>
 15e:	dd79                	beqz	a0,13c <find+0x13c>
 160:	85d6                	mv	a1,s5
 162:	db240513          	addi	a0,s0,-590
 166:	090000ef          	jal	1f6 <strcmp>
 16a:	d969                	beqz	a0,13c <find+0x13c>
                memmove(p, de.name, DIRSIZ);
 16c:	4639                	li	a2,14
 16e:	db240593          	addi	a1,s0,-590
 172:	855a                	mv	a0,s6
 174:	210000ef          	jal	384 <memmove>
                p[DIRSIZ] = 0;
 178:	000907a3          	sb	zero,15(s2)
                find(buf, filename);
 17c:	85ce                	mv	a1,s3
 17e:	dc040513          	addi	a0,s0,-576
 182:	e7fff0ef          	jal	0 <find>
 186:	bf5d                	j	13c <find+0x13c>
 188:	24013a03          	ld	s4,576(sp)
 18c:	23813a83          	ld	s5,568(sp)
 190:	23013b03          	ld	s6,560(sp)
 194:	b5cd                	j	76 <find+0x76>

0000000000000196 <main>:


int main(int argc, char *argv[]) {
 196:	1141                	addi	sp,sp,-16
 198:	e406                	sd	ra,8(sp)
 19a:	e022                	sd	s0,0(sp)
 19c:	0800                	addi	s0,sp,16
    // 参数个数如果不为3，则返回异常
    if (argc != 3) {
 19e:	470d                	li	a4,3
 1a0:	00e50c63          	beq	a0,a4,1b8 <main+0x22>
        fprintf(2, "Usage: find directory filename\n");
 1a4:	00001597          	auipc	a1,0x1
 1a8:	8c458593          	addi	a1,a1,-1852 # a68 <malloc+0x16a>
 1ac:	4509                	li	a0,2
 1ae:	672000ef          	jal	820 <fprintf>
        exit(1);
 1b2:	4505                	li	a0,1
 1b4:	27e000ef          	jal	432 <exit>
 1b8:	87ae                	mv	a5,a1
    }

    find(argv[1], argv[2]);
 1ba:	698c                	ld	a1,16(a1)
 1bc:	6788                	ld	a0,8(a5)
 1be:	e43ff0ef          	jal	0 <find>

    exit(0);
 1c2:	4501                	li	a0,0
 1c4:	26e000ef          	jal	432 <exit>

00000000000001c8 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 1c8:	1141                	addi	sp,sp,-16
 1ca:	e406                	sd	ra,8(sp)
 1cc:	e022                	sd	s0,0(sp)
 1ce:	0800                	addi	s0,sp,16
  extern int main();
  main();
 1d0:	fc7ff0ef          	jal	196 <main>
  exit(0);
 1d4:	4501                	li	a0,0
 1d6:	25c000ef          	jal	432 <exit>

00000000000001da <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1da:	1141                	addi	sp,sp,-16
 1dc:	e422                	sd	s0,8(sp)
 1de:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1e0:	87aa                	mv	a5,a0
 1e2:	0585                	addi	a1,a1,1
 1e4:	0785                	addi	a5,a5,1
 1e6:	fff5c703          	lbu	a4,-1(a1)
 1ea:	fee78fa3          	sb	a4,-1(a5)
 1ee:	fb75                	bnez	a4,1e2 <strcpy+0x8>
    ;
  return os;
}
 1f0:	6422                	ld	s0,8(sp)
 1f2:	0141                	addi	sp,sp,16
 1f4:	8082                	ret

00000000000001f6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1f6:	1141                	addi	sp,sp,-16
 1f8:	e422                	sd	s0,8(sp)
 1fa:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1fc:	00054783          	lbu	a5,0(a0)
 200:	cb91                	beqz	a5,214 <strcmp+0x1e>
 202:	0005c703          	lbu	a4,0(a1)
 206:	00f71763          	bne	a4,a5,214 <strcmp+0x1e>
    p++, q++;
 20a:	0505                	addi	a0,a0,1
 20c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 20e:	00054783          	lbu	a5,0(a0)
 212:	fbe5                	bnez	a5,202 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 214:	0005c503          	lbu	a0,0(a1)
}
 218:	40a7853b          	subw	a0,a5,a0
 21c:	6422                	ld	s0,8(sp)
 21e:	0141                	addi	sp,sp,16
 220:	8082                	ret

0000000000000222 <strlen>:

uint
strlen(const char *s)
{
 222:	1141                	addi	sp,sp,-16
 224:	e422                	sd	s0,8(sp)
 226:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 228:	00054783          	lbu	a5,0(a0)
 22c:	cf91                	beqz	a5,248 <strlen+0x26>
 22e:	0505                	addi	a0,a0,1
 230:	87aa                	mv	a5,a0
 232:	86be                	mv	a3,a5
 234:	0785                	addi	a5,a5,1
 236:	fff7c703          	lbu	a4,-1(a5)
 23a:	ff65                	bnez	a4,232 <strlen+0x10>
 23c:	40a6853b          	subw	a0,a3,a0
 240:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 242:	6422                	ld	s0,8(sp)
 244:	0141                	addi	sp,sp,16
 246:	8082                	ret
  for(n = 0; s[n]; n++)
 248:	4501                	li	a0,0
 24a:	bfe5                	j	242 <strlen+0x20>

000000000000024c <memset>:

void*
memset(void *dst, int c, uint n)
{
 24c:	1141                	addi	sp,sp,-16
 24e:	e422                	sd	s0,8(sp)
 250:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 252:	ca19                	beqz	a2,268 <memset+0x1c>
 254:	87aa                	mv	a5,a0
 256:	1602                	slli	a2,a2,0x20
 258:	9201                	srli	a2,a2,0x20
 25a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 25e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 262:	0785                	addi	a5,a5,1
 264:	fee79de3          	bne	a5,a4,25e <memset+0x12>
  }
  return dst;
}
 268:	6422                	ld	s0,8(sp)
 26a:	0141                	addi	sp,sp,16
 26c:	8082                	ret

000000000000026e <strchr>:

char*
strchr(const char *s, char c)
{
 26e:	1141                	addi	sp,sp,-16
 270:	e422                	sd	s0,8(sp)
 272:	0800                	addi	s0,sp,16
  for(; *s; s++)
 274:	00054783          	lbu	a5,0(a0)
 278:	cb99                	beqz	a5,28e <strchr+0x20>
    if(*s == c)
 27a:	00f58763          	beq	a1,a5,288 <strchr+0x1a>
  for(; *s; s++)
 27e:	0505                	addi	a0,a0,1
 280:	00054783          	lbu	a5,0(a0)
 284:	fbfd                	bnez	a5,27a <strchr+0xc>
      return (char*)s;
  return 0;
 286:	4501                	li	a0,0
}
 288:	6422                	ld	s0,8(sp)
 28a:	0141                	addi	sp,sp,16
 28c:	8082                	ret
  return 0;
 28e:	4501                	li	a0,0
 290:	bfe5                	j	288 <strchr+0x1a>

0000000000000292 <gets>:

char*
gets(char *buf, int max)
{
 292:	711d                	addi	sp,sp,-96
 294:	ec86                	sd	ra,88(sp)
 296:	e8a2                	sd	s0,80(sp)
 298:	e4a6                	sd	s1,72(sp)
 29a:	e0ca                	sd	s2,64(sp)
 29c:	fc4e                	sd	s3,56(sp)
 29e:	f852                	sd	s4,48(sp)
 2a0:	f456                	sd	s5,40(sp)
 2a2:	f05a                	sd	s6,32(sp)
 2a4:	ec5e                	sd	s7,24(sp)
 2a6:	1080                	addi	s0,sp,96
 2a8:	8baa                	mv	s7,a0
 2aa:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2ac:	892a                	mv	s2,a0
 2ae:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2b0:	4aa9                	li	s5,10
 2b2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2b4:	89a6                	mv	s3,s1
 2b6:	2485                	addiw	s1,s1,1
 2b8:	0344d663          	bge	s1,s4,2e4 <gets+0x52>
    cc = read(0, &c, 1);
 2bc:	4605                	li	a2,1
 2be:	faf40593          	addi	a1,s0,-81
 2c2:	4501                	li	a0,0
 2c4:	186000ef          	jal	44a <read>
    if(cc < 1)
 2c8:	00a05e63          	blez	a0,2e4 <gets+0x52>
    buf[i++] = c;
 2cc:	faf44783          	lbu	a5,-81(s0)
 2d0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2d4:	01578763          	beq	a5,s5,2e2 <gets+0x50>
 2d8:	0905                	addi	s2,s2,1
 2da:	fd679de3          	bne	a5,s6,2b4 <gets+0x22>
    buf[i++] = c;
 2de:	89a6                	mv	s3,s1
 2e0:	a011                	j	2e4 <gets+0x52>
 2e2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2e4:	99de                	add	s3,s3,s7
 2e6:	00098023          	sb	zero,0(s3)
  return buf;
}
 2ea:	855e                	mv	a0,s7
 2ec:	60e6                	ld	ra,88(sp)
 2ee:	6446                	ld	s0,80(sp)
 2f0:	64a6                	ld	s1,72(sp)
 2f2:	6906                	ld	s2,64(sp)
 2f4:	79e2                	ld	s3,56(sp)
 2f6:	7a42                	ld	s4,48(sp)
 2f8:	7aa2                	ld	s5,40(sp)
 2fa:	7b02                	ld	s6,32(sp)
 2fc:	6be2                	ld	s7,24(sp)
 2fe:	6125                	addi	sp,sp,96
 300:	8082                	ret

0000000000000302 <stat>:

int
stat(const char *n, struct stat *st)
{
 302:	1101                	addi	sp,sp,-32
 304:	ec06                	sd	ra,24(sp)
 306:	e822                	sd	s0,16(sp)
 308:	e04a                	sd	s2,0(sp)
 30a:	1000                	addi	s0,sp,32
 30c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 30e:	4581                	li	a1,0
 310:	162000ef          	jal	472 <open>
  if(fd < 0)
 314:	02054263          	bltz	a0,338 <stat+0x36>
 318:	e426                	sd	s1,8(sp)
 31a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 31c:	85ca                	mv	a1,s2
 31e:	16c000ef          	jal	48a <fstat>
 322:	892a                	mv	s2,a0
  close(fd);
 324:	8526                	mv	a0,s1
 326:	134000ef          	jal	45a <close>
  return r;
 32a:	64a2                	ld	s1,8(sp)
}
 32c:	854a                	mv	a0,s2
 32e:	60e2                	ld	ra,24(sp)
 330:	6442                	ld	s0,16(sp)
 332:	6902                	ld	s2,0(sp)
 334:	6105                	addi	sp,sp,32
 336:	8082                	ret
    return -1;
 338:	597d                	li	s2,-1
 33a:	bfcd                	j	32c <stat+0x2a>

000000000000033c <atoi>:

int
atoi(const char *s)
{
 33c:	1141                	addi	sp,sp,-16
 33e:	e422                	sd	s0,8(sp)
 340:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 342:	00054683          	lbu	a3,0(a0)
 346:	fd06879b          	addiw	a5,a3,-48
 34a:	0ff7f793          	zext.b	a5,a5
 34e:	4625                	li	a2,9
 350:	02f66863          	bltu	a2,a5,380 <atoi+0x44>
 354:	872a                	mv	a4,a0
  n = 0;
 356:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 358:	0705                	addi	a4,a4,1
 35a:	0025179b          	slliw	a5,a0,0x2
 35e:	9fa9                	addw	a5,a5,a0
 360:	0017979b          	slliw	a5,a5,0x1
 364:	9fb5                	addw	a5,a5,a3
 366:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 36a:	00074683          	lbu	a3,0(a4)
 36e:	fd06879b          	addiw	a5,a3,-48
 372:	0ff7f793          	zext.b	a5,a5
 376:	fef671e3          	bgeu	a2,a5,358 <atoi+0x1c>
  return n;
}
 37a:	6422                	ld	s0,8(sp)
 37c:	0141                	addi	sp,sp,16
 37e:	8082                	ret
  n = 0;
 380:	4501                	li	a0,0
 382:	bfe5                	j	37a <atoi+0x3e>

0000000000000384 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 384:	1141                	addi	sp,sp,-16
 386:	e422                	sd	s0,8(sp)
 388:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 38a:	02b57463          	bgeu	a0,a1,3b2 <memmove+0x2e>
    while(n-- > 0)
 38e:	00c05f63          	blez	a2,3ac <memmove+0x28>
 392:	1602                	slli	a2,a2,0x20
 394:	9201                	srli	a2,a2,0x20
 396:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 39a:	872a                	mv	a4,a0
      *dst++ = *src++;
 39c:	0585                	addi	a1,a1,1
 39e:	0705                	addi	a4,a4,1
 3a0:	fff5c683          	lbu	a3,-1(a1)
 3a4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3a8:	fef71ae3          	bne	a4,a5,39c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3ac:	6422                	ld	s0,8(sp)
 3ae:	0141                	addi	sp,sp,16
 3b0:	8082                	ret
    dst += n;
 3b2:	00c50733          	add	a4,a0,a2
    src += n;
 3b6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3b8:	fec05ae3          	blez	a2,3ac <memmove+0x28>
 3bc:	fff6079b          	addiw	a5,a2,-1
 3c0:	1782                	slli	a5,a5,0x20
 3c2:	9381                	srli	a5,a5,0x20
 3c4:	fff7c793          	not	a5,a5
 3c8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3ca:	15fd                	addi	a1,a1,-1
 3cc:	177d                	addi	a4,a4,-1
 3ce:	0005c683          	lbu	a3,0(a1)
 3d2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3d6:	fee79ae3          	bne	a5,a4,3ca <memmove+0x46>
 3da:	bfc9                	j	3ac <memmove+0x28>

00000000000003dc <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3dc:	1141                	addi	sp,sp,-16
 3de:	e422                	sd	s0,8(sp)
 3e0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3e2:	ca05                	beqz	a2,412 <memcmp+0x36>
 3e4:	fff6069b          	addiw	a3,a2,-1
 3e8:	1682                	slli	a3,a3,0x20
 3ea:	9281                	srli	a3,a3,0x20
 3ec:	0685                	addi	a3,a3,1
 3ee:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3f0:	00054783          	lbu	a5,0(a0)
 3f4:	0005c703          	lbu	a4,0(a1)
 3f8:	00e79863          	bne	a5,a4,408 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3fc:	0505                	addi	a0,a0,1
    p2++;
 3fe:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 400:	fed518e3          	bne	a0,a3,3f0 <memcmp+0x14>
  }
  return 0;
 404:	4501                	li	a0,0
 406:	a019                	j	40c <memcmp+0x30>
      return *p1 - *p2;
 408:	40e7853b          	subw	a0,a5,a4
}
 40c:	6422                	ld	s0,8(sp)
 40e:	0141                	addi	sp,sp,16
 410:	8082                	ret
  return 0;
 412:	4501                	li	a0,0
 414:	bfe5                	j	40c <memcmp+0x30>

0000000000000416 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 416:	1141                	addi	sp,sp,-16
 418:	e406                	sd	ra,8(sp)
 41a:	e022                	sd	s0,0(sp)
 41c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 41e:	f67ff0ef          	jal	384 <memmove>
}
 422:	60a2                	ld	ra,8(sp)
 424:	6402                	ld	s0,0(sp)
 426:	0141                	addi	sp,sp,16
 428:	8082                	ret

000000000000042a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 42a:	4885                	li	a7,1
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <exit>:
.global exit
exit:
 li a7, SYS_exit
 432:	4889                	li	a7,2
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <wait>:
.global wait
wait:
 li a7, SYS_wait
 43a:	488d                	li	a7,3
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 442:	4891                	li	a7,4
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <read>:
.global read
read:
 li a7, SYS_read
 44a:	4895                	li	a7,5
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <write>:
.global write
write:
 li a7, SYS_write
 452:	48c1                	li	a7,16
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <close>:
.global close
close:
 li a7, SYS_close
 45a:	48d5                	li	a7,21
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <kill>:
.global kill
kill:
 li a7, SYS_kill
 462:	4899                	li	a7,6
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <exec>:
.global exec
exec:
 li a7, SYS_exec
 46a:	489d                	li	a7,7
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <open>:
.global open
open:
 li a7, SYS_open
 472:	48bd                	li	a7,15
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 47a:	48c5                	li	a7,17
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 482:	48c9                	li	a7,18
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 48a:	48a1                	li	a7,8
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <link>:
.global link
link:
 li a7, SYS_link
 492:	48cd                	li	a7,19
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 49a:	48d1                	li	a7,20
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4a2:	48a5                	li	a7,9
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <dup>:
.global dup
dup:
 li a7, SYS_dup
 4aa:	48a9                	li	a7,10
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4b2:	48ad                	li	a7,11
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4ba:	48b1                	li	a7,12
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4c2:	48b5                	li	a7,13
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4ca:	48b9                	li	a7,14
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4d2:	1101                	addi	sp,sp,-32
 4d4:	ec06                	sd	ra,24(sp)
 4d6:	e822                	sd	s0,16(sp)
 4d8:	1000                	addi	s0,sp,32
 4da:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4de:	4605                	li	a2,1
 4e0:	fef40593          	addi	a1,s0,-17
 4e4:	f6fff0ef          	jal	452 <write>
}
 4e8:	60e2                	ld	ra,24(sp)
 4ea:	6442                	ld	s0,16(sp)
 4ec:	6105                	addi	sp,sp,32
 4ee:	8082                	ret

00000000000004f0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4f0:	7139                	addi	sp,sp,-64
 4f2:	fc06                	sd	ra,56(sp)
 4f4:	f822                	sd	s0,48(sp)
 4f6:	f426                	sd	s1,40(sp)
 4f8:	0080                	addi	s0,sp,64
 4fa:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4fc:	c299                	beqz	a3,502 <printint+0x12>
 4fe:	0805c963          	bltz	a1,590 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 502:	2581                	sext.w	a1,a1
  neg = 0;
 504:	4881                	li	a7,0
 506:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 50a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 50c:	2601                	sext.w	a2,a2
 50e:	00000517          	auipc	a0,0x0
 512:	58250513          	addi	a0,a0,1410 # a90 <digits>
 516:	883a                	mv	a6,a4
 518:	2705                	addiw	a4,a4,1
 51a:	02c5f7bb          	remuw	a5,a1,a2
 51e:	1782                	slli	a5,a5,0x20
 520:	9381                	srli	a5,a5,0x20
 522:	97aa                	add	a5,a5,a0
 524:	0007c783          	lbu	a5,0(a5)
 528:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 52c:	0005879b          	sext.w	a5,a1
 530:	02c5d5bb          	divuw	a1,a1,a2
 534:	0685                	addi	a3,a3,1
 536:	fec7f0e3          	bgeu	a5,a2,516 <printint+0x26>
  if(neg)
 53a:	00088c63          	beqz	a7,552 <printint+0x62>
    buf[i++] = '-';
 53e:	fd070793          	addi	a5,a4,-48
 542:	00878733          	add	a4,a5,s0
 546:	02d00793          	li	a5,45
 54a:	fef70823          	sb	a5,-16(a4)
 54e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 552:	02e05a63          	blez	a4,586 <printint+0x96>
 556:	f04a                	sd	s2,32(sp)
 558:	ec4e                	sd	s3,24(sp)
 55a:	fc040793          	addi	a5,s0,-64
 55e:	00e78933          	add	s2,a5,a4
 562:	fff78993          	addi	s3,a5,-1
 566:	99ba                	add	s3,s3,a4
 568:	377d                	addiw	a4,a4,-1
 56a:	1702                	slli	a4,a4,0x20
 56c:	9301                	srli	a4,a4,0x20
 56e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 572:	fff94583          	lbu	a1,-1(s2)
 576:	8526                	mv	a0,s1
 578:	f5bff0ef          	jal	4d2 <putc>
  while(--i >= 0)
 57c:	197d                	addi	s2,s2,-1
 57e:	ff391ae3          	bne	s2,s3,572 <printint+0x82>
 582:	7902                	ld	s2,32(sp)
 584:	69e2                	ld	s3,24(sp)
}
 586:	70e2                	ld	ra,56(sp)
 588:	7442                	ld	s0,48(sp)
 58a:	74a2                	ld	s1,40(sp)
 58c:	6121                	addi	sp,sp,64
 58e:	8082                	ret
    x = -xx;
 590:	40b005bb          	negw	a1,a1
    neg = 1;
 594:	4885                	li	a7,1
    x = -xx;
 596:	bf85                	j	506 <printint+0x16>

0000000000000598 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 598:	711d                	addi	sp,sp,-96
 59a:	ec86                	sd	ra,88(sp)
 59c:	e8a2                	sd	s0,80(sp)
 59e:	e0ca                	sd	s2,64(sp)
 5a0:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5a2:	0005c903          	lbu	s2,0(a1)
 5a6:	26090863          	beqz	s2,816 <vprintf+0x27e>
 5aa:	e4a6                	sd	s1,72(sp)
 5ac:	fc4e                	sd	s3,56(sp)
 5ae:	f852                	sd	s4,48(sp)
 5b0:	f456                	sd	s5,40(sp)
 5b2:	f05a                	sd	s6,32(sp)
 5b4:	ec5e                	sd	s7,24(sp)
 5b6:	e862                	sd	s8,16(sp)
 5b8:	e466                	sd	s9,8(sp)
 5ba:	8b2a                	mv	s6,a0
 5bc:	8a2e                	mv	s4,a1
 5be:	8bb2                	mv	s7,a2
  state = 0;
 5c0:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5c2:	4481                	li	s1,0
 5c4:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5c6:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5ca:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5ce:	06c00c93          	li	s9,108
 5d2:	a005                	j	5f2 <vprintf+0x5a>
        putc(fd, c0);
 5d4:	85ca                	mv	a1,s2
 5d6:	855a                	mv	a0,s6
 5d8:	efbff0ef          	jal	4d2 <putc>
 5dc:	a019                	j	5e2 <vprintf+0x4a>
    } else if(state == '%'){
 5de:	03598263          	beq	s3,s5,602 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 5e2:	2485                	addiw	s1,s1,1
 5e4:	8726                	mv	a4,s1
 5e6:	009a07b3          	add	a5,s4,s1
 5ea:	0007c903          	lbu	s2,0(a5)
 5ee:	20090c63          	beqz	s2,806 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 5f2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5f6:	fe0994e3          	bnez	s3,5de <vprintf+0x46>
      if(c0 == '%'){
 5fa:	fd579de3          	bne	a5,s5,5d4 <vprintf+0x3c>
        state = '%';
 5fe:	89be                	mv	s3,a5
 600:	b7cd                	j	5e2 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 602:	00ea06b3          	add	a3,s4,a4
 606:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 60a:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 60c:	c681                	beqz	a3,614 <vprintf+0x7c>
 60e:	9752                	add	a4,a4,s4
 610:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 614:	03878f63          	beq	a5,s8,652 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 618:	05978963          	beq	a5,s9,66a <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 61c:	07500713          	li	a4,117
 620:	0ee78363          	beq	a5,a4,706 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 624:	07800713          	li	a4,120
 628:	12e78563          	beq	a5,a4,752 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 62c:	07000713          	li	a4,112
 630:	14e78a63          	beq	a5,a4,784 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 634:	07300713          	li	a4,115
 638:	18e78a63          	beq	a5,a4,7cc <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 63c:	02500713          	li	a4,37
 640:	04e79563          	bne	a5,a4,68a <vprintf+0xf2>
        putc(fd, '%');
 644:	02500593          	li	a1,37
 648:	855a                	mv	a0,s6
 64a:	e89ff0ef          	jal	4d2 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 64e:	4981                	li	s3,0
 650:	bf49                	j	5e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 652:	008b8913          	addi	s2,s7,8
 656:	4685                	li	a3,1
 658:	4629                	li	a2,10
 65a:	000ba583          	lw	a1,0(s7)
 65e:	855a                	mv	a0,s6
 660:	e91ff0ef          	jal	4f0 <printint>
 664:	8bca                	mv	s7,s2
      state = 0;
 666:	4981                	li	s3,0
 668:	bfad                	j	5e2 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 66a:	06400793          	li	a5,100
 66e:	02f68963          	beq	a3,a5,6a0 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 672:	06c00793          	li	a5,108
 676:	04f68263          	beq	a3,a5,6ba <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 67a:	07500793          	li	a5,117
 67e:	0af68063          	beq	a3,a5,71e <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 682:	07800793          	li	a5,120
 686:	0ef68263          	beq	a3,a5,76a <vprintf+0x1d2>
        putc(fd, '%');
 68a:	02500593          	li	a1,37
 68e:	855a                	mv	a0,s6
 690:	e43ff0ef          	jal	4d2 <putc>
        putc(fd, c0);
 694:	85ca                	mv	a1,s2
 696:	855a                	mv	a0,s6
 698:	e3bff0ef          	jal	4d2 <putc>
      state = 0;
 69c:	4981                	li	s3,0
 69e:	b791                	j	5e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6a0:	008b8913          	addi	s2,s7,8
 6a4:	4685                	li	a3,1
 6a6:	4629                	li	a2,10
 6a8:	000ba583          	lw	a1,0(s7)
 6ac:	855a                	mv	a0,s6
 6ae:	e43ff0ef          	jal	4f0 <printint>
        i += 1;
 6b2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6b4:	8bca                	mv	s7,s2
      state = 0;
 6b6:	4981                	li	s3,0
        i += 1;
 6b8:	b72d                	j	5e2 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6ba:	06400793          	li	a5,100
 6be:	02f60763          	beq	a2,a5,6ec <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6c2:	07500793          	li	a5,117
 6c6:	06f60963          	beq	a2,a5,738 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6ca:	07800793          	li	a5,120
 6ce:	faf61ee3          	bne	a2,a5,68a <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d2:	008b8913          	addi	s2,s7,8
 6d6:	4681                	li	a3,0
 6d8:	4641                	li	a2,16
 6da:	000ba583          	lw	a1,0(s7)
 6de:	855a                	mv	a0,s6
 6e0:	e11ff0ef          	jal	4f0 <printint>
        i += 2;
 6e4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6e6:	8bca                	mv	s7,s2
      state = 0;
 6e8:	4981                	li	s3,0
        i += 2;
 6ea:	bde5                	j	5e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6ec:	008b8913          	addi	s2,s7,8
 6f0:	4685                	li	a3,1
 6f2:	4629                	li	a2,10
 6f4:	000ba583          	lw	a1,0(s7)
 6f8:	855a                	mv	a0,s6
 6fa:	df7ff0ef          	jal	4f0 <printint>
        i += 2;
 6fe:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 700:	8bca                	mv	s7,s2
      state = 0;
 702:	4981                	li	s3,0
        i += 2;
 704:	bdf9                	j	5e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 706:	008b8913          	addi	s2,s7,8
 70a:	4681                	li	a3,0
 70c:	4629                	li	a2,10
 70e:	000ba583          	lw	a1,0(s7)
 712:	855a                	mv	a0,s6
 714:	dddff0ef          	jal	4f0 <printint>
 718:	8bca                	mv	s7,s2
      state = 0;
 71a:	4981                	li	s3,0
 71c:	b5d9                	j	5e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 71e:	008b8913          	addi	s2,s7,8
 722:	4681                	li	a3,0
 724:	4629                	li	a2,10
 726:	000ba583          	lw	a1,0(s7)
 72a:	855a                	mv	a0,s6
 72c:	dc5ff0ef          	jal	4f0 <printint>
        i += 1;
 730:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 732:	8bca                	mv	s7,s2
      state = 0;
 734:	4981                	li	s3,0
        i += 1;
 736:	b575                	j	5e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 738:	008b8913          	addi	s2,s7,8
 73c:	4681                	li	a3,0
 73e:	4629                	li	a2,10
 740:	000ba583          	lw	a1,0(s7)
 744:	855a                	mv	a0,s6
 746:	dabff0ef          	jal	4f0 <printint>
        i += 2;
 74a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 74c:	8bca                	mv	s7,s2
      state = 0;
 74e:	4981                	li	s3,0
        i += 2;
 750:	bd49                	j	5e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 752:	008b8913          	addi	s2,s7,8
 756:	4681                	li	a3,0
 758:	4641                	li	a2,16
 75a:	000ba583          	lw	a1,0(s7)
 75e:	855a                	mv	a0,s6
 760:	d91ff0ef          	jal	4f0 <printint>
 764:	8bca                	mv	s7,s2
      state = 0;
 766:	4981                	li	s3,0
 768:	bdad                	j	5e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 76a:	008b8913          	addi	s2,s7,8
 76e:	4681                	li	a3,0
 770:	4641                	li	a2,16
 772:	000ba583          	lw	a1,0(s7)
 776:	855a                	mv	a0,s6
 778:	d79ff0ef          	jal	4f0 <printint>
        i += 1;
 77c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 77e:	8bca                	mv	s7,s2
      state = 0;
 780:	4981                	li	s3,0
        i += 1;
 782:	b585                	j	5e2 <vprintf+0x4a>
 784:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 786:	008b8d13          	addi	s10,s7,8
 78a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 78e:	03000593          	li	a1,48
 792:	855a                	mv	a0,s6
 794:	d3fff0ef          	jal	4d2 <putc>
  putc(fd, 'x');
 798:	07800593          	li	a1,120
 79c:	855a                	mv	a0,s6
 79e:	d35ff0ef          	jal	4d2 <putc>
 7a2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7a4:	00000b97          	auipc	s7,0x0
 7a8:	2ecb8b93          	addi	s7,s7,748 # a90 <digits>
 7ac:	03c9d793          	srli	a5,s3,0x3c
 7b0:	97de                	add	a5,a5,s7
 7b2:	0007c583          	lbu	a1,0(a5)
 7b6:	855a                	mv	a0,s6
 7b8:	d1bff0ef          	jal	4d2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7bc:	0992                	slli	s3,s3,0x4
 7be:	397d                	addiw	s2,s2,-1
 7c0:	fe0916e3          	bnez	s2,7ac <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 7c4:	8bea                	mv	s7,s10
      state = 0;
 7c6:	4981                	li	s3,0
 7c8:	6d02                	ld	s10,0(sp)
 7ca:	bd21                	j	5e2 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 7cc:	008b8993          	addi	s3,s7,8
 7d0:	000bb903          	ld	s2,0(s7)
 7d4:	00090f63          	beqz	s2,7f2 <vprintf+0x25a>
        for(; *s; s++)
 7d8:	00094583          	lbu	a1,0(s2)
 7dc:	c195                	beqz	a1,800 <vprintf+0x268>
          putc(fd, *s);
 7de:	855a                	mv	a0,s6
 7e0:	cf3ff0ef          	jal	4d2 <putc>
        for(; *s; s++)
 7e4:	0905                	addi	s2,s2,1
 7e6:	00094583          	lbu	a1,0(s2)
 7ea:	f9f5                	bnez	a1,7de <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 7ec:	8bce                	mv	s7,s3
      state = 0;
 7ee:	4981                	li	s3,0
 7f0:	bbcd                	j	5e2 <vprintf+0x4a>
          s = "(null)";
 7f2:	00000917          	auipc	s2,0x0
 7f6:	29690913          	addi	s2,s2,662 # a88 <malloc+0x18a>
        for(; *s; s++)
 7fa:	02800593          	li	a1,40
 7fe:	b7c5                	j	7de <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 800:	8bce                	mv	s7,s3
      state = 0;
 802:	4981                	li	s3,0
 804:	bbf9                	j	5e2 <vprintf+0x4a>
 806:	64a6                	ld	s1,72(sp)
 808:	79e2                	ld	s3,56(sp)
 80a:	7a42                	ld	s4,48(sp)
 80c:	7aa2                	ld	s5,40(sp)
 80e:	7b02                	ld	s6,32(sp)
 810:	6be2                	ld	s7,24(sp)
 812:	6c42                	ld	s8,16(sp)
 814:	6ca2                	ld	s9,8(sp)
    }
  }
}
 816:	60e6                	ld	ra,88(sp)
 818:	6446                	ld	s0,80(sp)
 81a:	6906                	ld	s2,64(sp)
 81c:	6125                	addi	sp,sp,96
 81e:	8082                	ret

0000000000000820 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 820:	715d                	addi	sp,sp,-80
 822:	ec06                	sd	ra,24(sp)
 824:	e822                	sd	s0,16(sp)
 826:	1000                	addi	s0,sp,32
 828:	e010                	sd	a2,0(s0)
 82a:	e414                	sd	a3,8(s0)
 82c:	e818                	sd	a4,16(s0)
 82e:	ec1c                	sd	a5,24(s0)
 830:	03043023          	sd	a6,32(s0)
 834:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 838:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 83c:	8622                	mv	a2,s0
 83e:	d5bff0ef          	jal	598 <vprintf>
}
 842:	60e2                	ld	ra,24(sp)
 844:	6442                	ld	s0,16(sp)
 846:	6161                	addi	sp,sp,80
 848:	8082                	ret

000000000000084a <printf>:

void
printf(const char *fmt, ...)
{
 84a:	711d                	addi	sp,sp,-96
 84c:	ec06                	sd	ra,24(sp)
 84e:	e822                	sd	s0,16(sp)
 850:	1000                	addi	s0,sp,32
 852:	e40c                	sd	a1,8(s0)
 854:	e810                	sd	a2,16(s0)
 856:	ec14                	sd	a3,24(s0)
 858:	f018                	sd	a4,32(s0)
 85a:	f41c                	sd	a5,40(s0)
 85c:	03043823          	sd	a6,48(s0)
 860:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 864:	00840613          	addi	a2,s0,8
 868:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 86c:	85aa                	mv	a1,a0
 86e:	4505                	li	a0,1
 870:	d29ff0ef          	jal	598 <vprintf>
}
 874:	60e2                	ld	ra,24(sp)
 876:	6442                	ld	s0,16(sp)
 878:	6125                	addi	sp,sp,96
 87a:	8082                	ret

000000000000087c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 87c:	1141                	addi	sp,sp,-16
 87e:	e422                	sd	s0,8(sp)
 880:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 882:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 886:	00000797          	auipc	a5,0x0
 88a:	77a7b783          	ld	a5,1914(a5) # 1000 <freep>
 88e:	a02d                	j	8b8 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 890:	4618                	lw	a4,8(a2)
 892:	9f2d                	addw	a4,a4,a1
 894:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 898:	6398                	ld	a4,0(a5)
 89a:	6310                	ld	a2,0(a4)
 89c:	a83d                	j	8da <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 89e:	ff852703          	lw	a4,-8(a0)
 8a2:	9f31                	addw	a4,a4,a2
 8a4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8a6:	ff053683          	ld	a3,-16(a0)
 8aa:	a091                	j	8ee <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ac:	6398                	ld	a4,0(a5)
 8ae:	00e7e463          	bltu	a5,a4,8b6 <free+0x3a>
 8b2:	00e6ea63          	bltu	a3,a4,8c6 <free+0x4a>
{
 8b6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b8:	fed7fae3          	bgeu	a5,a3,8ac <free+0x30>
 8bc:	6398                	ld	a4,0(a5)
 8be:	00e6e463          	bltu	a3,a4,8c6 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8c2:	fee7eae3          	bltu	a5,a4,8b6 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8c6:	ff852583          	lw	a1,-8(a0)
 8ca:	6390                	ld	a2,0(a5)
 8cc:	02059813          	slli	a6,a1,0x20
 8d0:	01c85713          	srli	a4,a6,0x1c
 8d4:	9736                	add	a4,a4,a3
 8d6:	fae60de3          	beq	a2,a4,890 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8da:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8de:	4790                	lw	a2,8(a5)
 8e0:	02061593          	slli	a1,a2,0x20
 8e4:	01c5d713          	srli	a4,a1,0x1c
 8e8:	973e                	add	a4,a4,a5
 8ea:	fae68ae3          	beq	a3,a4,89e <free+0x22>
    p->s.ptr = bp->s.ptr;
 8ee:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8f0:	00000717          	auipc	a4,0x0
 8f4:	70f73823          	sd	a5,1808(a4) # 1000 <freep>
}
 8f8:	6422                	ld	s0,8(sp)
 8fa:	0141                	addi	sp,sp,16
 8fc:	8082                	ret

00000000000008fe <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8fe:	7139                	addi	sp,sp,-64
 900:	fc06                	sd	ra,56(sp)
 902:	f822                	sd	s0,48(sp)
 904:	f426                	sd	s1,40(sp)
 906:	ec4e                	sd	s3,24(sp)
 908:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 90a:	02051493          	slli	s1,a0,0x20
 90e:	9081                	srli	s1,s1,0x20
 910:	04bd                	addi	s1,s1,15
 912:	8091                	srli	s1,s1,0x4
 914:	0014899b          	addiw	s3,s1,1
 918:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 91a:	00000517          	auipc	a0,0x0
 91e:	6e653503          	ld	a0,1766(a0) # 1000 <freep>
 922:	c915                	beqz	a0,956 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 924:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 926:	4798                	lw	a4,8(a5)
 928:	08977a63          	bgeu	a4,s1,9bc <malloc+0xbe>
 92c:	f04a                	sd	s2,32(sp)
 92e:	e852                	sd	s4,16(sp)
 930:	e456                	sd	s5,8(sp)
 932:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 934:	8a4e                	mv	s4,s3
 936:	0009871b          	sext.w	a4,s3
 93a:	6685                	lui	a3,0x1
 93c:	00d77363          	bgeu	a4,a3,942 <malloc+0x44>
 940:	6a05                	lui	s4,0x1
 942:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 946:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 94a:	00000917          	auipc	s2,0x0
 94e:	6b690913          	addi	s2,s2,1718 # 1000 <freep>
  if(p == (char*)-1)
 952:	5afd                	li	s5,-1
 954:	a081                	j	994 <malloc+0x96>
 956:	f04a                	sd	s2,32(sp)
 958:	e852                	sd	s4,16(sp)
 95a:	e456                	sd	s5,8(sp)
 95c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 95e:	00000797          	auipc	a5,0x0
 962:	6b278793          	addi	a5,a5,1714 # 1010 <base>
 966:	00000717          	auipc	a4,0x0
 96a:	68f73d23          	sd	a5,1690(a4) # 1000 <freep>
 96e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 970:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 974:	b7c1                	j	934 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 976:	6398                	ld	a4,0(a5)
 978:	e118                	sd	a4,0(a0)
 97a:	a8a9                	j	9d4 <malloc+0xd6>
  hp->s.size = nu;
 97c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 980:	0541                	addi	a0,a0,16
 982:	efbff0ef          	jal	87c <free>
  return freep;
 986:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 98a:	c12d                	beqz	a0,9ec <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 98c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 98e:	4798                	lw	a4,8(a5)
 990:	02977263          	bgeu	a4,s1,9b4 <malloc+0xb6>
    if(p == freep)
 994:	00093703          	ld	a4,0(s2)
 998:	853e                	mv	a0,a5
 99a:	fef719e3          	bne	a4,a5,98c <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 99e:	8552                	mv	a0,s4
 9a0:	b1bff0ef          	jal	4ba <sbrk>
  if(p == (char*)-1)
 9a4:	fd551ce3          	bne	a0,s5,97c <malloc+0x7e>
        return 0;
 9a8:	4501                	li	a0,0
 9aa:	7902                	ld	s2,32(sp)
 9ac:	6a42                	ld	s4,16(sp)
 9ae:	6aa2                	ld	s5,8(sp)
 9b0:	6b02                	ld	s6,0(sp)
 9b2:	a03d                	j	9e0 <malloc+0xe2>
 9b4:	7902                	ld	s2,32(sp)
 9b6:	6a42                	ld	s4,16(sp)
 9b8:	6aa2                	ld	s5,8(sp)
 9ba:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9bc:	fae48de3          	beq	s1,a4,976 <malloc+0x78>
        p->s.size -= nunits;
 9c0:	4137073b          	subw	a4,a4,s3
 9c4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9c6:	02071693          	slli	a3,a4,0x20
 9ca:	01c6d713          	srli	a4,a3,0x1c
 9ce:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9d0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9d4:	00000717          	auipc	a4,0x0
 9d8:	62a73623          	sd	a0,1580(a4) # 1000 <freep>
      return (void*)(p + 1);
 9dc:	01078513          	addi	a0,a5,16
  }
}
 9e0:	70e2                	ld	ra,56(sp)
 9e2:	7442                	ld	s0,48(sp)
 9e4:	74a2                	ld	s1,40(sp)
 9e6:	69e2                	ld	s3,24(sp)
 9e8:	6121                	addi	sp,sp,64
 9ea:	8082                	ret
 9ec:	7902                	ld	s2,32(sp)
 9ee:	6a42                	ld	s4,16(sp)
 9f0:	6aa2                	ld	s5,8(sp)
 9f2:	6b02                	ld	s6,0(sp)
 9f4:	b7f5                	j	9e0 <malloc+0xe2>
