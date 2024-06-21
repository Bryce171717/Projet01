import org.apache.spark.sql.SparkSession
import com.mongodb.spark._
import com.mongodb.spark.config._

object MainClass {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession.builder()
      .appName("ReadFromMongoDB")
      .getOrCreate()

    val readConfig = ReadConfig(Map("uri" -> "mongodb://admin01:1234@172.31.39.95:27017/database01.collection"))
    val mongoRDD = MongoSpark.load(spark.sparkContext, readConfig)
    mongoRDD.take(10).foreach(println)

    spark.stop()
  }
}
