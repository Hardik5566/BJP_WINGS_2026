using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

using System.Web;

/// <summary>
/// Summary description for command
/// </summary>
public class command
{
	public command()
	{
		//
		// TODO: Add constructor logic here
		//
	}

    //public static int ExtQuery(SqlCommand cmd)
    //{
    //    using (SqlConnection cn = connection.open_connection())
    //    {
    //        cmd.CommandType = CommandType.StoredProcedure;
    //        cmd.Connection = cn;

    //        cn.Open();   // REQUIRED for ExecuteNonQuery
    //        return cmd.ExecuteNonQuery();
    //    } // ✅ connection closed + disposed here
    //}

    //// Return DataTable
    //public static DataTable ExtQueryDT(SqlCommand cmd)
    //{
    //    using (SqlConnection cn = connection.open_connection())
    //    {
    //        cmd.CommandType = CommandType.StoredProcedure;
    //        cmd.Connection = cn;

    //        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
    //        {
    //            DataTable dt = new DataTable();
    //            da.Fill(dt);   // Adapter opens/closes automatically
    //            return dt;
    //        }
    //    }
    //}

    //// Return DataSet
    //public static DataSet ExtQueryDS(SqlCommand cmd)
    //{
    //    using (SqlConnection cn = connection.open_connection())
    //    {
    //        cmd.CommandType = CommandType.StoredProcedure;
    //        cmd.Connection = cn;

    //        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
    //        {
    //            DataSet ds = new DataSet();
    //            da.Fill(ds);   // Adapter opens/closes automatically
    //            return ds;
    //        }
    //    }
    //}

    public static int ExtQuery(SqlCommand cmd)
    {
        using (SqlConnection cn = connection.open_connection())
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Connection = cn;

            cn.Open();   // REQUIRED for ExecuteNonQuery
            return cmd.ExecuteNonQuery();
        } // ✅ connection closed + disposed here
    }

    // Return DataTable
    public static DataTable ExtQueryDT(SqlCommand cmd)
    {
        using (SqlConnection cn = connection.open_connection())
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Connection = cn;

            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                DataTable dt = new DataTable();
                da.Fill(dt);   // Adapter opens/closes automatically
                return dt;
            }
        }
    }

    // Return DataSet
    public static DataSet ExtQueryDS(SqlCommand cmd)
    {
        using (SqlConnection cn = connection.open_connection())
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Connection = cn;

            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                DataSet ds = new DataSet();
                da.Fill(ds);   // Adapter opens/closes automatically
                return ds;
            }
        }
    }
}