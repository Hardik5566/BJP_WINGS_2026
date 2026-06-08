using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;

using System.Web;

/// <summary>
/// Summary description for parameter
/// </summary>
public class parameter
{
	public parameter()
	{
		//
		// TODO: Add constructor logic here
		//
	}
    private static object ToDbValue(string value)
    {
        return string.IsNullOrWhiteSpace(value) ? (object)DBNull.Value : value.Trim();
    }

    public SqlParameter intparam(string name, string value)
    {
        SqlParameter param = new SqlParameter();
        param.SqlDbType = SqlDbType.Int;
        param.ParameterName = name;
        int parsedValue;
        param.Value = int.TryParse(value, out parsedValue) ? (object)parsedValue : DBNull.Value;
        return param;
    }

    public SqlParameter bigintparam(string name, string value)
    {
        SqlParameter param = new SqlParameter();
        param.SqlDbType = SqlDbType.BigInt;
        param.ParameterName = name;
        long parsedValue;
        param.Value = long.TryParse(value, NumberStyles.Integer, CultureInfo.InvariantCulture, out parsedValue)
            ? (object)parsedValue
            : DBNull.Value;
        return param;
    }

    public SqlParameter floatparam(string name, string value)
    {
        SqlParameter param = new SqlParameter();
        param.SqlDbType = SqlDbType.Float;
        param.ParameterName = name;
        double parsedValue;
        param.Value = double.TryParse(value, NumberStyles.Any, CultureInfo.InvariantCulture, out parsedValue)
            ? (object)parsedValue
            : DBNull.Value;
        return param;
    }

    public SqlParameter stringparam(string name, string value)
    {
        SqlParameter param = new SqlParameter();
        param.SqlDbType = SqlDbType.NVarChar;
        param.ParameterName = name;
        param.Value = ToDbValue(value);
        return param;
    }

    public SqlParameter datetimeparam(string name, string value)
    {
        SqlParameter param = new SqlParameter();
        param.SqlDbType = SqlDbType.DateTime;
        param.ParameterName = name;
        DateTime parsedValue;
        param.Value = DateTime.TryParse(value, out parsedValue) ? (object)parsedValue : DBNull.Value;
        return param;
    }

    public SqlParameter boolparam(string name, string value)
    {
        SqlParameter param = new SqlParameter();
        param.SqlDbType = SqlDbType.Bit;
        param.ParameterName = name;
        bool parsedValue;
        param.Value = bool.TryParse(value, out parsedValue) ? (object)parsedValue : DBNull.Value;
        return param;
    }

    public SqlParameter TableParam(string paramName, DataTable table, string typeName)
    {
        return new SqlParameter
        {
            ParameterName = paramName,
            SqlDbType = SqlDbType.Structured,
            TypeName = typeName,   // Pass the SQL Server Table Type dynamically
            Value = table ?? (object)DBNull.Value
        };
    }
}