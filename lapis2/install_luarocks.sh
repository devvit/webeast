#

openresty_dir=`asdf where openresty`

cd /tmp

curl -fSL -O https://luarocks.org/releases/luarocks-3.8.0.tar.gz
tar -xf luarocks*.gz
rm -rf luarocks*.gz
cd luarocks*
./configure --prefix=$openresty_dir/luajit --with-lua=$openresty_dir/luajit
# ./configure --prefix=$openresty_dir/luajit --with-lua-bin=$openresty_dir/luajit/bin --with-lua-include=$openresty_dir/luajit/include/luajit-2.1 --lua-suffix=jit
make || exit 1
make install || exit 1
