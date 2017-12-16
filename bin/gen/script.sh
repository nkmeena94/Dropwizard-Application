#! /bin/bash
root="../../"
core_dir="$root/core"
base_dir="$root/master"
data_dir=$root/"db/gen/"
gen_db=$base_dir"/src/gen/java/com/xeno/db"
main_db=$base_dir"/src/main/java/com/xeno/db"
db=$base_dir"/src/gen/resources/migrations/db.changelog-1.0.sql.gen"
gen_core=$core_dir"/src/gen/java/com/xeno/core/entity"
main_core=$core_dir"/src/main/java/com/xeno/core/entity"
moduleconfig=$base_dir"/src/gen/java/com/xeno/fnd/server/AppModule.java.template"

function db_index() {
	table_name=$1
	input=$2
    file=$3
	idx_type=$4
    for cols in `echo $input | tr ':' ' '`
    do 
	    keys="`echo $cols | tr '+' ','`"
        idx_name=`echo $keys | tr -cd [A-Za-z0-9]`
        echo "create $idx_type index ${table_name}_${idx_name} on ${table_name}(${keys});" >> $file
    done
}

#rm -rf $gen_db $gen_core
mkdir -p $base_dir/src/gen/resources/migrations
mkdir -p $base_dir"/src/gen/java/com/xeno/fnd/server"
mkdir -p $gen_db/dao $gen_db/mapper $gen_core $data_dir
rm -f $moduleconfig
echo "--liquibase formatted sql

--changeset gen:1" > $db
rm -f moduleconfig
for line in `cat entities.csv  | sed "s/ //g" | sed 's/"//g'` 
do 
    x=`echo $line | cut -f1 -d','`
    echo $x
    unique_keys=`echo $line | cut -f2 -d','`
    idx_keys=`echo $line | cut -f3 -d','`
    entity_extends=`echo $line | cut -f4 -d','`
    dao_extends=`echo $line | cut -f5 -d','`

    y=`echo $line | cut -f6- -d','` 
    table=`echo 'create table ' $x ' ('` 
    clazzname=$x
    clazznamel=`echo $x | tr [A-Z] [a-z]`
    unset content
    unset content1
    unset contentupdate
    unset contentcolon
    unset contentz
    unset contenttypes
    unset autogenkey_annotation
    unset typeheader
    tostring='"'
    return_autogenkey="long"
    contento="select "	
    skip=true
    skip1=true
    for attr in `echo $y | tr ',' ' '`
    do 
        unset type1
        name=`echo $attr | cut -f1 -d'-'`
	    namel=`echo $name | tr [A-Z] [a-z]`
	    nameu=`echo $name | sed -e "s/\b\(.\)/\u\1/g"`
        typedb=`echo $attr | cut -f2 -d'-' | tr '.' ','`
        typeext=`echo $attr | cut -f3- -d'-' | tr '.' ','`
        type1=`echo $typedb | cut -f1 -d'-' | tr -cd '[A-Za-z]' | tr '[A-Z]' '[a-z]'`
	    case "$type1" in
   	    	"int") dbtype="INT";classtype="int";gettype="obj."set$nameu'(r.getInt("'$namel'"));';ann=""
   	    	;;
   	    	"long") dbtype="BIGINT";classtype="long";gettype="obj."set$nameu'(r.getLong("'$namel'"));';ann=""
   	    	;;
   	    	"nnint") dbtype="INT NOT NULL";classtype="Integer";gettype="obj."set$nameu'(r.getInt("'$namel'"));';ann=""
   	    	;;
   	    	"nnlong") dbtype="BIGINT NOT NULL";classtype="Long";gettype="obj."set$nameu'(r.getLong("'$namel'"));';ann=""
   	    	;;
   	    	"longauto") dbtype="BIGINT NOT NULL AUTO_INCREMENT";classtype="Long";gettype="obj."set$nameu'(r.getLong("'$namel'"));';ann="";autogenkey_annotation="@GetGeneratedKeys"
   	    	;;
   	    	"decimal") 
                	len=`echo $typedb | tr ':' ','`
                	dbtype=$len;classtype="double";gettype="obj."set$nameu'(r.getDouble("'$namel'"));';ann=""
   	    	;;
   	    	"nndecimal") 
                	len=`echo $typedb | sed "s/nndecimal//" | tr ':' ','`
                	dbtype="decimal"$len;classtype="Double";gettype="obj."set$nameu'(r.getDouble("'$namel'"));';ann=""
   	    	;;
   	    	"datetime") dbtype="DATETIME";classtype="Date";gettype="obj."set$nameu'(r.getTimestamp("'$namel'"));';ann=""
   	    	;;
   	    	"nndatetime") dbtype="DATETIME NOT NULL";classtype="Date";gettype="obj."set$nameu'(r.getTimestamp("'$namel'"));';ann=""
   	    	;;
   	    	"text") dbtype="text";classtype="String";gettype="obj."set$nameu'(r.getString("'$namel'"));';ann=""
   	    	;;
   	    	"nntext") dbtype="text Not Null";classtype="String";gettype="obj."set$nameu'(r.getString("'$namel'"));';ann="@NotBlank\n"
   	    	;;
   	    	"v")
                	len=`echo $typedb | tr -d "[A-Za-z]"`
                	dbtype="varchar("$len")";classtype="String";gettype="obj."set$nameu'(r.getString("'$namel'"));';ann="@Size(max=$len)\n"
   	    	;;
   	    	"nnv")
                	len=`echo $typedb | tr -d "[A-Za-z]"`
                	dbtype="varchar("$len") Not Null";classtype="String";gettype="obj."set$nameu'(r.getString("'$namel'"));';ann="@NotBlank\n@Size(max=$len)\n"
   	    	;;
   	    	"regv")
                	len=`echo $typedb | tr -d "[A-Za-z]"`
                	regex=`echo $typeext | tr '~' ','` 
                	dbtype="varchar("$len") Not Null";classtype="String";gettype="obj."set$nameu'(r.getString("'$namel'"));';ann="@NotBlank\n@Size(max=$len)\n@Pattern(regexp=\"$regex\")\n"
   	    	;;
   	    	"email")
                	dbtype="varchar(50)";classtype="String";gettype="obj."set$nameu'(r.getString("'$namel'"));';ann="@Email\n"
   	    	;;
   	    	"nnemail")
                	dbtype="varchar(50) Not Null";classtype="String";gettype="obj."set$nameu'(r.getString("'$namel'"));';ann="@Email\n@NotBlank\n"
            	;;
   	    	"nnphone")
                	dbtype="varchar(13) Not Null";classtype="String";gettype="obj."set$nameu'(r.getString("'$namel'"));';ann="@NotBlank\n@Pattern(regexp=\"[0-9]{10}\")"
            	;;
   	    	"phone")
                	dbtype="varchar(13)";classtype="String";gettype="obj."set$nameu'(r.getString("'$namel'"));';ann="@Pattern(regexp=\"[0-9]{10}\")"
            	;;
   	    	"enum") 
                	enum=`echo $typeext | cut -f1 -d'='`
                	typeheader=$typeheader"`echo $typeext | cut -f2- -d'='`"
                	dbtype="varchar(50)";classtype="String";gettype="obj."set$nameu'(r.getString("'$namel'"));';ann="@VerifyType(value = "$enum".class , groups = { "$enum".class })"
   	    	;;
   	    	"tinyint") dbtype=$typedb;classtype="int";gettype="obj."set$nameu'(r.getInt("'$namel'"));';ann=""
   	    	;;
   	    	*) dbtype="VARCHAR(50)";classtype="String";gettype="obj."set$nameu'(r.getString("'$namel'"));';ann=""
   	    	;;
	    esac
	    [ ! -z $skip ] && primaryId=$name && primary_key=$namel && primary_key_type=$classtype 
	    [ -z $skip ] && table=$table" , " && contento=$contento" , "  && content1=$content1" , " && contentcolon=$contentcolon" , " && contenttypes=$contenttypes"," && tostring=$tostring'+",' 
            typeheader=$typeheader${ann}","
	    content="${content}\n${ann}""@JsonProperty\nprivate $classtype $name ;\npublic $classtype get${nameu}() {return $name;}\npublic void set$nameu($classtype $name) { this.$name = $name;}\n"
	    contentz=$contentz" $gettype\n"
	    contento="$contento $namel"
	    contenttypes="$contenttypes ${classtype}"
            table="$table $name $dbtype"
	    content1="$content1 $namel"
	    contentcolon="$contentcolon :$name"
	    tostring=${tostring}${name}':"+'$name;
	    [ -z "$skip1" ] && contentupdate=$contentupdate" , "
	    if [ "$name" != "$primaryId" ] 
	    then 
	    	contentupdate="$contentupdate $namel = :$name" 
	    	unset skip1
	    fi
	    unset skip
    done
    #geneate bindings
    echo "bind(${clazzname}DAO.class).toInstance(dbi.onDemand(${clazzname}DAO.class));" >> $moduleconfig

    #generate blank data csv 
    echo $contenttypes | sed "s/ //g" > ${data_dir}/${clazznamel}.csv
    echo $typeheader >> ${data_dir}/${clazznamel}.csv
    echo $contento | sed "s/select//g" | sed "s/ //g" >> ${data_dir}/${clazznamel}.csv

    #generate ddls
    contentupdate="$contentupdate where $primary_key = :$primaryId"
    contento=$contento" from $clazznamel where "$primary_key" =:key" 
    table=$table" , primary key(${primary_key}))  ENGINE=innodb;"
    echo $table | tr [A-Z] [a-z] >> $db
    [ ! -z "$idx_keys" ] && db_index $clazznamel $idx_keys $db
    [ ! -z "$unique_keys" ] && db_index $clazznamel $unique_keys $db "unique"
    echo >> $db

    #generate Entity
    entityName=$x
    [ ! -z "$entity_extends" ] && entityName="_"$x 
    sed "s/classname/${entityName}/g" object > $gen_core/${entityName}.java	
    sed -i "s/content/$content/g" $gen_core/${entityName}.java 	
    sed -i "s/tostringdata/$tostring/g" $gen_core/${entityName}.java 	
    [ ! -z "$entity_extends" -a ! -e "$main_core/${x}.java" ] && sed "s/classname/${clazzname}/g" object_extends > $main_core/${x}.java	

    #generate Mappers
    sed "s/classname/$clazzname/g" mapp > $gen_db/mapper/${x}Mapper.java	
    sed -i "s/contentz/$contentz/g"  $gen_db/mapper/${x}Mapper.java	

    #generate DAO
    daoName=$x
    registermapper="@RegisterMapper(${x}Mapper.class)"
    unset registermapper_ex
    [ "$dao_extends" == "y" ] && daoName="_"$x && unset registermapper && registermapper_ex="@RegisterMapper(${x}Mapper.class)"
    sed "s/classnamel/$clazznamel/g" interface > $gen_db/dao/${daoName}DAO.java	
    sed -i "s/classname/$clazzname/g"  $gen_db/dao/${daoName}DAO.java	
    sed -i "s/daoname/$daoName/g"  $gen_db/dao/${daoName}DAO.java	
    sed -i "s/contento/$contento/g"  $gen_db/dao/${daoName}DAO.java	
    sed -i "s/contentcolon/$contentcolon/g"  $gen_db/dao/${daoName}DAO.java	
    sed -i "s/primarykey/$primary_key/g"  $gen_db/dao/${daoName}DAO.java	
    sed -i "s/key_type/$primary_key_type/g"  $gen_db/dao/${daoName}DAO.java	
    sed -i "s/content1/$content1/g"  $gen_db/dao/${daoName}DAO.java	
    sed -i "s/contentupdate/$contentupdate/g"  $gen_db/dao/${daoName}DAO.java	
    sed -i "s/return_autogenkey/$return_autogenkey/g"  $gen_db/dao/${daoName}DAO.java	
    sed -i "s/autogenkey_annotation/$autogenkey_annotation/g"  $gen_db/dao/${daoName}DAO.java	
    sed -i "s/registermapper/$registermapper/g"  $gen_db/dao/${daoName}DAO.java	
    if [ "$dao_extends" == "y" -a ! -e "$main_db/dao/${x}DAO.java" ]
    then
        sed "s/classname/$clazzname/g" interface_extends > $main_db/dao/${x}DAO.java	
        sed -i "s/contento/$contento/g"  $main_db/dao/${x}DAO.java	
        sed -i "s/contentupdate/$contentupdate/g"  $main_db/dao/${x}DAO.java	
    	sed -i "s/registermapper/$registermapper_ex/g"  $main_db/dao/${x}DAO.java	
    fi
done
