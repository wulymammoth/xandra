defmodule DataTypesTest do
  use ExUnit.Case

  defp with_test_keyspace(fun) do
    {:ok, conn} = Xandra.start_link()
    try do
      {:ok, _} = Xandra.execute(conn, "CREATE KEYSPACE xandra_test WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1}", [], [])
      {:ok, _} = Xandra.execute(conn, "USE xandra_test", [], [])
      fun.(conn)
    after
      Xandra.execute(conn, "DROP KEYSPACE xandra_test", [], [])
    end
  end

  test "primitive datatypes" do
    with_test_keyspace(fn conn ->
      try do
        statement = """
        CREATE TABLE primitives
        (id int PRIMARY KEY,
         ascii ascii,
         bigint bigint,
         blob blob,
         boolean boolean,
         decimal decimal,
         double double,
         float float,
         inet inet,
         int int,
         text text,
         timestamp timestamp,
         timeuuid timeuuid,
         uuid uuid,
         varchar varchar,
         varint varint)
        """
        {:ok, _} = Xandra.execute(conn, statement, [], [])

        {:ok, _} = Xandra.execute(conn, "INSERT INTO primitives (id) VALUES (1)", [], [])
        {:ok, rows} = Xandra.execute(conn, "SELECT * FROM primitives WHERE id = 1", [], [])

        assert [row] = Enum.to_list(rows)
        assert row["id"] == 1
        assert row["ascii"] == nil
        assert row["bigint"] == nil
        assert row["blob"] == nil
        assert row["boolean"] == nil
        assert row["decimal"] == nil
        assert row["double"] == nil
        assert row["float"] == nil
        assert row["inet"] == nil
        assert row["int"] == nil
        assert row["text"] == nil
        assert row["timestamp"] == nil
        assert row["timeuuid"] == nil
        assert row["uuid"] == nil
        assert row["varchar"] == nil
        assert row["varint"] == nil

        statement = """
        INSERT INTO primitives
        (id,
         ascii,
         bigint,
         blob,
         boolean,
         decimal,
         double,
         float,
         inet,
         int,
         text,
         timestamp,
         timeuuid,
         uuid,
         varchar,
         varint)
        VALUES
        (1,
         'ascii',
         1000000000,
         0x00FF,
         true,
         13.23,
         3.1415,
         -1.25,
         '192.168.0.1',
         42,
         'эликсир',
         2167219200,
         fe2b4360-28c6-11e2-81c1-0800200c9a66,
         00b69180-d0e1-11e2-8b8b-0800200c9a66,
         'тоже эликсир',
         6789065678192312391879827349)
        """
        {:ok, _} = Xandra.execute(conn, statement, [], [])
        {:ok, rows} = Xandra.execute(conn, "SELECT * FROM primitives WHERE id = 1", [], [])
        assert [row] = Enum.to_list(rows)
        assert row["ascii"] == "ascii"
        assert row["bigint"] == 1000000000
        assert row["blob"] == <<0, 0xFF>>
        assert row["boolean"] == true
        assert row["decimal"] == {1323, 2}
        assert row["double"] == 3.1415
        assert row["float"] == -1.25
        assert row["inet"] == {192, 168, 0, 1}
        assert row["int"] == 42
        assert row["text"] == "эликсир"
        assert row["timestamp"] == 2167219200
        assert row["timeuuid"] == <<254, 43, 67, 96, 40, 198, 17, 226, 129, 193, 8, 0, 32, 12, 154, 102>>
        assert row["uuid"] == <<0, 182, 145, 128, 208, 225, 17, 226, 139, 139, 8, 0, 32, 12, 154, 102>>
        assert row["varchar"] == "тоже эликсир"
        assert row["varint"] == 6789065678192312391879827349
      after
        Xandra.execute(conn, "DROP TABLE primitives", [], [])
      end
    end)
  end
end
