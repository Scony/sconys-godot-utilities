#include <Godot.hpp>
#include <Reference.hpp>

#include "Delaunator.hpp"

using namespace godot;

class GeometryNG : public Reference
{
  GODOT_CLASS(GeometryNG, Reference);

 public:
  GeometryNG() {}

  /** `_init` must exist as it is called by Godot. */
  void _init() {}

  PoolVector2Array triangulate_delaunay_2d(PoolVector2Array input_points)
  {
    PoolVector2Array ret;
    std::vector<double> coords{};
    coords.reserve(input_points.size());
    for (unsigned i = 0; i < input_points.size(); i++)
    {
      coords.emplace_back(static_cast<double>(input_points[i].x));
      coords.emplace_back(static_cast<double>(input_points[i].y));
    }
    delaunator::Delaunator d(coords);
    for (std::size_t i = 0; i < d.triangles.size(); i += 3)
    {
      ret.append(Vector2(d.coords[2 * d.triangles[i]], d.coords[2 * d.triangles[i] + 1]));
      ret.append(Vector2(d.coords[2 * d.triangles[i + 1]], d.coords[2 * d.triangles[i + 1] + 1]));
      ret.append(Vector2(d.coords[2 * d.triangles[i + 2]], d.coords[2 * d.triangles[i + 2] + 1]));
    }
    Godot::print(("GeometryNG::triangulate_delaunay_2d(): successfully triangulated " +
                  std::to_string(input_points.size()) + " vertices")
                     .c_str()); // TODO: seek godot's itos()
    return ret;
  }

  static void _register_methods()
  {
    register_method("triangulate_delaunay_2d", &GeometryNG::triangulate_delaunay_2d);
  }
};

/** GDNative Initialize **/
extern "C" void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options* o)
{
  godot::Godot::gdnative_init(o);
}

/** GDNative Terminate **/
extern "C" void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options* o)
{
  godot::Godot::gdnative_terminate(o);
}

/** NativeScript Initialize **/
extern "C" void GDN_EXPORT godot_nativescript_init(void* handle)
{
  godot::Godot::nativescript_init(handle);

  godot::register_class<GeometryNG>();
}
