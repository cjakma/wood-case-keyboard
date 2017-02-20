import argparse
import json
import re
import copy
import cmath

import matplotlib.pyplot as pl
from descartes import PolygonPatch
import shapely.ops as ops
import shapely.geometry as geometry
#  from shapely.ops import cascaded_union, polygonize
#  from scipy.spatial import Delaunay
#  import numpy as np
#  import math


deg_to_rad = cmath.pi / 180
unit = 19.05
inch = 25.4


def im_to_tuple(z):
    return (z.real, z.imag)


class Switch:
    def __init__(self, ori, name):
        self.name = name
        self.pos = ori.pos
        self.rot = ori.rot
        self.width = ori.w
        self.height = ori.h
        self.center = ori.getCenter()
        self.corners = ori.getCorners()
        self.row = ori.row

    def __repr__(self):
        return str(self.pos)

    def getShape(self):
        return geometry.Polygon([im_to_tuple(p) for p in self.corners]).buffer(0.2)

    def toList(self):
        return [[self.center.real, self.center.imag],
                self.rot, self.width, self.row]


class Orientation:

    def __init__(self):
        self.pivot = 0 + 0j
        self.ppivot = 0 + 0j
        self.dx = 1 + 0j
        self.dy = 0 - 1j
        self.pos = 0
        self.rot = 0
        self.w = 1
        self.h = 1
        self.row = 0

    def moveX(self, x):
        self.pos += self.dx * x * unit

    def moveY(self, y):
        self.pivot += self.dy * y * unit
        self.pos += self.dy * y * unit

    def rotate(self, r):
        self.rot = r
        self.dx = (1 + 0j) * cmath.exp(-1j*r*deg_to_rad)
        self.dy = (0 - 1j) * cmath.exp(-1j*r*deg_to_rad)

    def setX(self, x):
        self.ppivot = x*unit + self.ppivot.imag * 1j
        self.pivot = self.ppivot
        self.pos = self.pivot

    def setY(self, y):
        self.ppivot = self.pivot.real - y*unit*1j
        self.pivot = self.ppivot
        self.pos = self.pivot

    def nextRow(self):
        self.pivot += self.dy * unit
        self.pos = self.pivot
        self.row += 1

    def getCenter(self):
        return self.pos + (self.dx*self.w+self.dy*self.h)*unit/2

    def getCorners(self):
        return [self.pos,
                self.pos + self.dx*unit*self.w,
                self.pos + self.dx*unit*self.w + self.dy*unit*self.h,
                self.pos + self.dy*unit*self.h]

    def update(self, op):
        if 'r' in op:
            self.rotate(op["r"])
        if 'rx' in op:
            self.setX(op["rx"])
        if 'ry' in op:
            self.setY(op["ry"])
        if 'x' in op:
            self.moveX(op["x"])
        if 'y' in op:
            self.moveY(op["y"])
        if 'w' in op:
            self.w = op["w"]
        if 'h' in op:
            self.h = op["h"]

    def resetSize(self):
        self.w = 1
        self.h = 1

    def copy(self):
        return copy.copy(self)


def parseLayout(raw):
    def fix_json(raw):
        return re.sub(r'(\w+)\s*:', r'"\1":', raw.strip())

    data = json.loads('[' + fix_json(raw) + ']')
    ori = Orientation()
    switches = []
    for i, row in enumerate(data):
        for j, item in enumerate(row):
            if isinstance(item, str):
                switches.append(Switch(ori, item))
                ori.moveX(ori.w)
                ori.resetSize()
            else:
                ori.update(item)
        ori.nextRow()
    return switches


def plot_polygon(polygon):
    fig = pl.figure(figsize=(10, 10))
    ax = fig.add_subplot(111)
    margin = .3

    x_min, y_min, x_max, y_max = polygon.bounds

    ax.set_xlim([x_min-margin, x_max+margin])
    ax.set_ylim([y_min-margin, y_max+margin])
    patch = PolygonPatch(polygon, fc='#999999', ec='#000000', fill=True, zorder=-1)
    ax.add_patch(patch)
    return fig


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("layout", type=str,
                        help="File name which is containing layout \
                        information exported from keyboard-layout-editor")
    fname = parser.parse_args().layout
    with open(fname, "r") as f:
        raw = f.read()
    switches = parseLayout(raw)
    shapes = [sw.getShape() for sw in switches]
    plate = ops.cascaded_union(shapes)

    def save(name, val):
        print(name, '=', val, ';')

    minx, miny, maxx, maxy = plate.bounds
    save('plate_width', maxy - miny)
    save('plate_length', maxx - minx)
    save('plate_coords', [list(coord) for coord in plate.exterior.coords])
    save('switch_info', [sw.toList() for sw in switches])

#     plot_polygon(plate)
#     pl.show()
