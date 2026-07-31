#include <iostream>

constexpr double PI = 3.14159265358979323846;

//--------------------------------------------------
// Base class
//--------------------------------------------------
class Container
{
public:
    virtual ~Container() {}

    virtual double volume() const = 0;
    virtual double surfaceArea() const = 0;

    virtual void printInfo() const
    {
        std::cout << "Volume       : " << volume() << '\n';
        std::cout << "Surface Area : " << surfaceArea() << '\n';
    }
};

//--------------------------------------------------
// Box
//--------------------------------------------------
class BoxContainer : public Container
{
public:
    BoxContainer(double width, double height, double depth)
        : width_(width), height_(height), depth_(depth)
    {
    }

    double width() const { return width_; }
    double height() const { return height_; }
    double depth() const { return depth_; }

    double volume() const override
    {
        return width_ * height_ * depth_;
    }

    double surfaceArea() const override
    {
        return 2.0 * (
            width_ * height_ +
            width_ * depth_ +
            height_ * depth_);
    }

    void printInfo() const override
    {
        std::cout << "=== Box Container ===\n";
        std::cout << "Width : " << width_ << '\n';
        std::cout << "Height: " << height_ << '\n';
        std::cout << "Depth : " << depth_ << '\n';
        Container::printInfo();
    }

private:
    double width_;
    double height_;
    double depth_;
};

//--------------------------------------------------
// Sphere
//--------------------------------------------------
class SphereContainer : public Container
{
public:
    SphereContainer(double radius)
        : radius_(radius)
    {
    }

    double volume() const override
    {
        return (4.0 / 3.0) * PI * radius_ * radius_ * radius_;
    }

    double surfaceArea() const override
    {
        return 4.0 * PI * radius_ * radius_;
    }

    void printInfo() const override
    {
        std::cout << "=== Sphere Container ===\n";
        std::cout << "Radius: " << radius_ << '\n';
        Container::printInfo();
    }

private:
    double radius_;
};

//--------------------------------------------------
// Cylinder
//--------------------------------------------------
class CylinderContainer : public Container
{
public:
    CylinderContainer(double radius, double height)
        : radius_(radius), height_(height)
    {
    }

    double volume() const override
    {
        return PI * radius_ * radius_ * height_;
    }

    double surfaceArea() const override
    {
        return 2.0 * PI * radius_ * (radius_ + height_);
    }

    void printInfo() const override
    {
        std::cout << "=== Cylinder Container ===\n";
        std::cout << "Radius: " << radius_ << '\n';
        std::cout << "Height: " << height_ << '\n';
        Container::printInfo();
    }

private:
    double radius_;
    double height_;
};

//--------------------------------------------------
// Demo
//--------------------------------------------------
int main()
{
    BoxContainer box(2, 3, 4);
    SphereContainer sphere(5);
    CylinderContainer cylinder(2.5, 10);

    Container* containers[] =
    {
        &box,
        &sphere,
        &cylinder
    };

    for (int i = 0; i < 3; ++i)
    {
        containers[i]->printInfo();
        std::cout << '\n';
    }

    return 0;
}
