#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/xml_parser.hpp>
//#include <sstream>

struct cplex_solution
{
    std::string solutionStatusString;
    int solutionStatusValue;
};

// Loads debug_settings structure from the specified XML file
int main(int argc, char *argv[])
{
    std::string filename;
    if (argc > 1)
        filename= std::string(argv[1]);
    else
        filename= "irf_seminar-supd800-wgpd800-suad45_coverage.sol";

    std::ifstream my_file(filename);
    if (!my_file.good())
        exit(-1);
//    struct debug_settings
//{
//    std::string m_file;          // log filename
//    int m_level;                 // debug level
//    std::set<string> m_modules;  // modules where logging is enabled
//    void load(const std::string &filename);
//    void save(const std::string &filename);
//};
    // Create an empty property tree object
    using boost::property_tree::ptree;
    ptree pt;

    // Load the XML file into the property tree. If reading fails
    // (cannot open file, parse error), an exception is thrown.
    read_xml(filename, pt);

    //// Get the filename and store it in the m_file variable.
    //// Note that we construct the path to the value by separating
    //// the individual keys with dots. If dots appear in the keys,
    //// a path type with a different separator can be used.
    //// If the debug.filename key is not found, an exception is thrown.
    //m_file = pt.get<std::string>("debug.filename");
    int sstatv =  pt.get<int>("CPLEXSolution.header.<xmlattr>.solutionStatusValue");
    std::string sstatstr =  pt.get<std::string>("CPLEXSolution.header.<xmlattr>.solutionStatusString");

    std::cout << filename << " " << sstatv << " " << sstatstr;
    
    //// Get the debug level and store it in the m_level variable.
    //// This is another version of the get method: if the value is
    //// not found, the default value (specified by the second
    //// parameter) is returned instead. The type of the value
    //// extracted is determined by the type of the second parameter,
    //// so we can simply write get(...) instead of get<int>(...).
    //m_level = pt.get("debug.level", 0);

    //// Iterate over the debug.modules section and store all found
    //// modules in the m_modules set. The get_child() function
    //// returns a reference to the child at the specified path; if
    //// there is no such child, it throws. Property tree iterators
    //// are models of BidirectionalIterator.
    //BOOST_FOREACH(ptree::value_type &v,
    //        pt.get_child("debug.modules"))
    //    m_modules.insert(v.second.data());

//    std::ostream& operator <<(std::ostream& os, const tree_printer& p)
//{
//    const pt::ptree& tree = p.first;
//
//    if(tree.empty()) return os;
//
//    const std::string indent(p.second, ' ');
//
//    BOOST_FOREACH(const pt::ptree::value_type& v, tree)
//    {
//        const std::string& nodeName = v.first;
//
//        if(nodeName == "<xmlattr>") continue;
//
//        os << indent << nodeName;
//        const pt::ptree& attributes =
//            tree.get_child(nodeName + ".<xmlattr>", empty_ptree());
//
//        if(!attributes.empty())
//        {
//            os << " [ ";
//            BOOST_FOREACH(const pt::ptree::value_type& attr, attributes)
//            {
//                const std::string& attrName = attr.first;
//                const std::string& attrVal = attr.second.data();
//
//                os << attrName << " = '" << attrVal << "'; ";
//            }
//            os << "]";
//        }
//        os << "\n";
//
//        const pt::ptree& childNode = v.second;
//        os << tree_printer(childNode, p.second + 1);
//    }
//
//    return os;
//}

}