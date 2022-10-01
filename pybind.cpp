// https://stackoverflow.com/questions/42276984/hypot-has-not-been-declared
#ifdef _WIN64
#define _hypot hypot
#include <cmath>
#endif

#include <pybind11/pybind11.h>
#include <pybind11/eigen.h>
#include <pybind11/iostream.h>
#include <pybind11/pybind11.h>
#include <pybind11/stl.h>
#include <pybind11/stl_bind.h>

#include <tl/optional.hpp>

namespace py = pybind11;
using rvp = py::return_value_policy;
using namespace pybind11::literals;

#include "flatbush.h"
#include "linematch.hpp"
#include "intersections2d.hpp"

namespace pybind11
{
namespace detail
{
template <typename T>
struct type_caster<tl::optional<T>> : optional_caster<tl::optional<T>>
{
};
}
}

PYBIND11_MODULE(PYBIND11_PROJECT_NAME, m)
{
    m.doc() = "intersections2d";

    using FlatBush = flatbush::FlatBush<double>;
    py::class_<FlatBush>(m, "FlatBush", py::module_local())
        .def(py::init<>())
        .def(py::init<int>(), "reserve"_a)
        .def("reserve", &FlatBush::Reserve)
        .def("add", py::overload_cast<double, double, double, double, int, int>(
                        &FlatBush::Add),
             "minX"_a, "minY"_a, "maxX"_a, "maxY"_a, //
             py::kw_only(), "label0"_a = -1, "label1"_a = -1)
        .def("add",
             py::overload_cast<const Eigen::Ref<const FlatBush::PolylineType> &,
                               int>(&FlatBush::Add),
             "polyline"_a, //
             py::kw_only(), "label0"_a)

        .def("add",
             [](FlatBush &self, const Eigen::Vector4d &bbox, int label0,
                int label1) -> size_t {
                 return self.Add(bbox[0], bbox[1], bbox[2], bbox[3]);
             },
             "box"_a, py::kw_only(), "label0"_a = -1, "label1"_a = -1)
        .def("finish", &FlatBush::Finish)
        //
        .def("boxes", &FlatBush::boxes, rvp::reference_internal)
        .def("labels", &FlatBush::labels, rvp::reference_internal)
        .def("box", &FlatBush::box, "index"_a)
        .def("label", &FlatBush::label, "index"_a)
        //
        .def("search",
             [](const FlatBush &self, double minX, double minY, double maxX,
                double maxY) { return self.Search(minX, minY, maxX, maxY); },
             "minX"_a, "minY"_a, "maxX"_a, "maxY"_a)
        .def("search",
             [](const FlatBush &self, const Eigen::Vector4d &bbox) {
                 return self.Search(bbox[0], bbox[1], bbox[2], bbox[3]);
             },
             "bbox"_a)
        .def("search",
             [](const FlatBush &self, const Eigen::Vector2d &min,
                const Eigen::Vector2d &max) {
                 return self.Search(min[0], min[1], max[0], max[1]);
             },
             "min"_a, "max"_a)
        .def("size", &FlatBush::Size)
        //
        ;

    m.def("intersect_segments", &linematch::intersect_segments, "a1"_a, "a2"_a,
          "b1"_a, "b2"_a, "intersect of two line segments; Note that, if "
                          "seg1==seg2, will return None");

    using Intersections2d = cubao::Intersections2d;
    py::class_<Intersections2d>(m, "Intersections2d", py::module_local())
        .def(py::init<>())
        .def("add_polyline", &Intersections2d::add_polyline, "polyline"_a,
             py::kw_only(), "index"_a = -1, "add polyline to tree, you can "
                                            "provide your own polyline index, "
                                            "default: -1")
        .def("finish", &Intersections2d::finish, "finish to finalize indexing")
        .def("intersections",
             py::overload_cast<>(&Intersections2d::intersections, py::const_),
             "all segment intersections in tree")
        .def("intersections", py::overload_cast<const Eigen::Vector2d &,
                                                const Eigen::Vector2d &, bool>(
                                  &Intersections2d::intersections, py::const_),
             "from"_a, "to"_a, py::kw_only(), "dedup"_a = true,
             "crossing intersections with [from, to] segment "
             "(sorted by t ratio)")
        .def("intersections",
             py::overload_cast<
                 const Eigen::Ref<const Intersections2d::PolylineType> &, bool>(
                 &Intersections2d::intersections, py::const_),
             "polyline"_a, py::kw_only(), "dedup"_a = true,
             "crossing intersections with polyline (sorted by t ratio)")
        //
        .def("bush", &Intersections2d::bush, rvp::reference_internal)
        .def("num_poylines", &Intersections2d::num_poylines)
        //
        ;
}
