from argparse import ArgumentParser
import glob

import h5py


# Set size of computational box (I don't know)
origin = (0, 0, 0)
L = (1, 1, 1)


prefix = """<?xml version="1.0" encoding="utf-8"?>
<Xdmf xmlns:xi="http://www.w3.org/2001/XInclude" Version="2.1">
  <Domain>
    <Grid Name="Structured Grid" GridType="Collection" CollectionType="Temporal">
"""
suffix = """    </Grid>
  </Domain>
</Xdmf>"""

timeattr = """      <Time TimeType="List"><DataItem Format="XML" Dimensions="{0}"> {1} </DataItem></Time>"""

grid_prefix = """      <Grid GridType="Uniform">"""
grid_suffix = """      </Grid>"""

geometry = """        <Geometry Type="ORIGIN_DXDYDZ">
          <DataItem DataType="UInt" Dimensions="3" Format="XML" Precision="4">{0} {1} {2}</DataItem>
          <DataItem DataType="Float" Dimensions="3" Format="XML" Precision="4">{3} {4} {5}</DataItem>
        </Geometry>""".format(origin[0], origin[1], origin[2], L[0], L[1], L[2])

toporogy = """
        <Topology Dimensions="{0} {1} {2}" Type="3DCoRectMesh"/>"""

attribute = """
        <Attribute Name="{0}" Center="Node">
          <DataItem Format="HDF" NumberType="Float" Precision="{4}" Dimensions="{1} {1} {1}">
            {2}:/{0}/{3}
          </DataItem>
        </Attribute>"""


class Xdmf:
    def __init__(self, max_time=None, dims=None, precision=8):
        self.max_time = max_time
        self.dims = dims  # データのshape
        self.precision = precision  # 倍精度なら8
        self.timesteps = None  # list of list(filename, attr_name, time)
        self.names = []  # list of /"name"

    def add_hdf5(self, filename):
        h5 = h5py.File(filename, 'r')

        data = list(h5.values())[0]  # /data
        self.names.append(data.name.replace('/', ''))

        if self.dims is None:
            self.dims = list(data.values())[0].shape  # shape of /data/0
        if self.max_time is None:
            self.max_time = max(map(int, data.keys()))
        if self.timesteps is None:
            self.timesteps = [list() for t in range(0, self.max_time+1)]

        # /attr_name/key
        attr_name = list(h5.keys())[0]
        for key in data.keys():
            t = int(key)
            self.timesteps[t].append((filename, attr_name, key))

        h5.close()

    def save(self, filename):
        if filename is None:
            filename = '_'.join(self.names) + '.xdmf'
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(self.convert())

    def convert(self):
        text = prefix

        text += '\n' + self.timeattr()

        for t in range(0, self.max_time+1):
            text += '\n' + grid_prefix
            text += '\n' + self.toporogy()
            text += '\n' + self.geometory()
            text += '\n' + self.attribute(t)
            text += '\n' + grid_suffix

        text += '\n' + suffix
        return text

    def timeattr(self):
        steps = ' '.join(map(str, range(self.max_time+1)))
        return timeattr.format(self.max_time+1, steps)

    def toporogy(self):
        return toporogy.format(*self.dims)

    def geometory(self):
        return geometry

    def attribute(self, t):
        text = ''
        for filename, attr_name, time in self.timesteps[t]:
            text += attribute.format(
                attr_name,
                self.dims[0],
                filename,
                time,
                self.precision
            )
            text += '\n'
        return text


def glob_files(patterns):
    filenames = []
    for pattern in patterns:
        for filename in glob.glob(pattern):
            filenames.append(filename)
    return filenames


def arg_parse():
    parser = ArgumentParser(description='hdf5 to xdmf convertor')
    parser.add_argument('h5files', nargs='*',
                        help='hdf5 filename or glob pattern')
    parser.add_argument('--output', '-o', default=None,
                        help='output filename (default: group1_group2.xdmf)')
    return parser.parse_args()


def main():
    args = arg_parse()

    filenames = glob_files(args.h5files)

    xdmf = Xdmf()
    for filename in filenames:
        xdmf.add_hdf5(filename)
    xdmf.save(args.output)


if __name__ == '__main__':
    main()
