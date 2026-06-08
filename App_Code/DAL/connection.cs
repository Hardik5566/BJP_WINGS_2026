using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;

using System.Web;

/// <summary>
/// Summary description for connection
/// </summary>

public class connection
{
	public connection()
	{
		//
		// TODO: Add constructor logic here
		//
	}


    public static SqlConnection open_connection()
    {
        // DO NOT open here
        // Let caller decide OR DataAdapter handle it
        return new SqlConnection(
            ConfigurationManager.ConnectionStrings["myConnectionString"].ConnectionString
        );
    }
    //public static SqlConnection open_connection()
    //{
    //    // DO NOT open here
    //    // Let caller decide OR DataAdapter handle it
    //    return new SqlConnection(
    //        ConfigurationManager.ConnectionStrings["myConnectionString"].ConnectionString
    //    );
    //}


    public static void close_connection(SqlConnection cn)
    {
        if (cn == null)
        {
            return;
        }

        if (cn.State != System.Data.ConnectionState.Closed)
        {
            cn.Close();
        }

        cn.Dispose();
    }
}