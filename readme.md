# 帯電シミュレーション by EMSES
太陽風が吹き付ける月面の表面帯電現象シミュレーション用の実験セット
EMSES本体に関してはクラスルームから別途ダウンロードする必要あり





## 内容
### plasma.inp
EMSESで用いるパラメータファイルの解説

### exp_surface
太陽風が吹き付ける月面環境のシミュレーションフォルダー

パラメータ:
- グリッド幅: 0.5m
- シミュレーションサイズ - 32x32x256 grid
- プラズマ密度 - 5/cc
- プラズマ流速度 - 400km/s
- 熱速度 - 10eV
- 月面高度 - 60grid

|   ↓   ↓   ↓  | 256grid
|              |
|              |
|              |
|              |
|              |
|              |
|              |
|              |
|--------------| 60grid
|              |
|              |
|              |
---------------- 0grid


### exp_hole
太陽風が吹き付ける空洞(幅10x10grid, 深さ40grid)有り月面環境のシミュレーションフォルダー
設定してあるシミュレーションパラメータでは状態が収束しないため、step数を追加する必要あり

パラメータ:
- グリッド幅: 0.5m
- シミュレーションサイズ - 32x32x256 grid
- プラズマ密度 - 5/cc
- プラズマ流速度 - 400km/s
- 熱速度 - 10eV
- 月面高度 - 60grid

|   ↓   ↓   ↓  | 256grid
|              |
|              |
|              |
|              |
|              |
|              |
|              |
|    10grid    |
|-----    -----| 60grid
|    |    |    |
|    |    |    |
|    |----|    | 20grid
---------------- 0grid

### exp_surface_with_pe
太陽風が吹き付け、かつ、太陽光照射による光電子放出が存在する月面環境のシミュレーションフォルダー

パラメータ:
- グリッド幅: 0.5m
- シミュレーションサイズ - 32x32x256 grid
- プラズマ密度 - 5/cc
- プラズマ流速度 - 400km/s
- 熱速度 - 10eV
- 月面高度 - 60grid
- 光電子
    + 電流 - 4.5 μA/m^2
    + 温度 - 2.2eV


|   ↓   ↓   ↓  | 256grid
|              |
|              |
|              |
|              |
|              |
|              |
|              |
|       ↑ PE   |
|--------------| 60grid
|              |
|              |
|              |
---------------- 0grid



## その他必要なもの

### emses3d_ohhelp20
EMSES本体のソースコード
中身をいじってあるためGoogleクラスルームから要ダウンロード

初めにmakeで実行ファイル"mpiemses3d"をビルドすること

使用の際は、ビルドした実行ファイルをシミュレーションフォルダーにコピーし以下のコマンドで実行する。
(実際の仕様の際はjobファイルを作成しスパコンの実行キューに投入する)

\$ <MPI_EXEC> ./mpiemses3d plasma.inp
※ <MPI_EXEC>: MPI実行コマンド (camphor上では"aprun -n <NUMBER_OF_PROCESS>")




## TODO
EMSESのビルド及び各シミュレーションを実行しその結果の可視化を行う.

### 準備
- EMSESのビルド
\$ cd mpiemses3d_ohhelp20
\$ make clean
\$ make

- ビルドしたEMSESをシミュレーションフォルダーにコピー
\$ cp mpiemses3d_ohhelp20/mpiemses3d <simulation-folder>/

- 各シミュレーションフォルダ内のjobスクリプトの権限変更(必要ない可能性あり)
\$ chmod 755 <simulation-folder>/job.sh

- 各シミュレーションフォルダ内のjobスクリプトの変更(下記ツールを用いる場合必要なし)
\$ vim <simulation-folder>/job.sh
この後,使用するコア数等を適宜変更する(使用するプロセス数はplasma.inp内のnodes(:)の総積)

### 実行
\$ cd <simulation-folder>
\$ qsub job.sh

#### 下記ツールを用いる場合
\$ myqsub job.sh -d <simulation-folder>
myqsubコマンドは、シミュレーションフォルダー内のplasma.inpからnodes(:)を読み取りjob.shを書き換えたmyjob.shを作成し、myjob.shをジョブキューに投入する

### 解析
- paraviewを用いる場合
*.h5と*.xdmfをダウンロードし、paraviewにロードする
(私はやり方を知らないが、ダウンロードをせずに解析することもできるらしい？)

- pythonを用いる場合
  + ローカルで可視化する
    .h5をダウンロードし、h5pyやmatplotlib等を用いて可視化
  
  + スパコン上で可視化する
    jupyter lab上でh5pyやmatplotlib等を用いて可視化
    \$ jupyter lab --port <port-number>
  
  (+ 自作ライブラリemoutを用いて可視化)
    emoutというライブラリをインストールすればpython上での簡単な可視化が可能
    
    インストール
    \$ pip install --user emout

    実行
    \$ cd <simulation-folder>
    \$ python
    \$ python> import emout
    \$ python> data = emout.Emout('./')
    \$ python> data.phisp[istep, zlower:zupper, y, xlower:xupper].plot() # phisp.h5の二次元面を表示する場合
    \$ python> data.phisp[istep, zlower:zupper, y, xlower:xupper].plot(savefilename='phisp.png') # phisp.h5の二次元面を保存する場合
    \$ python> data.phisp[istep, zlower:zupper, y, x].plot() # phisp.h5のある一次元上を表示する場合





## 便利ツール集
### Camphor上でのコマンドツール: camptools ( https://github.com/Nkzono99/camptools )
よく使う操作をまとめたコマンドツール

インストール
\$ pip install --user camptools

### EMSESパラメータファイル生成ツール: emses_inp_generator ( https://github.com/Nkzono99/emses_inp_generator )
SI単位系からEMSES単位系に変換・plamsa.inpの生成を行うツール

インストール
  URLからローカルにダウンロード後以下のコマンドを実行
  \$ pip install --user -r requirements.txt

実行 (以下のどれかを実行)
 - batファイルをダブルクリック
 - \$ ./inpgen.bat
 - \$ python src/main.py

### EMSESシミュレーション結果可視化ツール: emout ( https://github.com/Nkzono99/emout )

インストール
\$ pip install --user emout





# その他
## EMSESシミュレーションを実行後、その結果を用いて追加stepのシミュレーションを行う
- 継続ジョブの実行
\$ mkdir <simulation-folder-new>
\$ cd <simulation-folder-new>
\$ cp ../<simulation-folder-old>/plasma.inp ./
\$ cp ../<simulation-folder-old>/generate_xdmf.py ./
\$ cp ../<simulation-folder-old>/mpiemses3d ./
\$ cp ../<simulation-folder-old>/job.sh ./
\$ ln -s ../<simulation-folder-old>/SNAPSHOT1 ./SNAPSHOT0

\$ vim plasma.inp
plasma.inp内のjobnum(1:2)を以下のように修正
  jobnum(1:2) = 1, 1

\$ "qsub job.sh" または "myqsub job.sh"

- ツール (in "camptools") を使った継続ジョブ実行
\$ extentsim <simulation-folder-old> <simulation-folder-new> -n <number-of-additional-step> --run
