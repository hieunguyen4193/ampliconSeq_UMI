apt-get install build-essential autoconf automake libtool
# git clone https://github.com/xflouris/PEAR.git
git clone https://github.com/tseemann/PEAR.git
cd PEAR
./autogen.sh
./configure
make
sudo make install
