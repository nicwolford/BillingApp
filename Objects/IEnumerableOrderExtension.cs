using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Reflection;

namespace ScreeningONE
{
    public enum SortDirection
    {
        Ascending, Descending
    }

    public static class IEnumerableOrderExtension
    {
        public static IOrderedEnumerable<T> Order<T>(this IEnumerable<T> Source, string MemberName, SortDirection SortDirection)
        {
            MemberInfo mi = typeof(T).GetField(MemberName);
            if (mi == null)
                mi = typeof(T).GetProperty(MemberName);
            if (mi == null)
                throw new InvalidOperationException("Field or property '" + MemberName + "' not found");

            // get the field or property's type, and make a delegate type that takes a T and returns this member's type
            Type MemberType = mi is FieldInfo ? (mi as FieldInfo).FieldType : (mi as PropertyInfo).PropertyType;
            Type DelegateType = typeof(Func<,>).MakeGenericType(typeof(T), MemberType);

            // we need to call ValueProxy.ReturnValue, which is a generic type
            MethodInfo GenericReturnValueMethod = typeof(ValueProxy).GetMethod("GetValue");
            // it's type parameters are MemberType and <T>, so we "make" a method to bake in those specific types
            MethodInfo GetValueMethod = GenericReturnValueMethod.MakeGenericMethod(MemberType, typeof(T));

            var proxy = new ValueProxy(mi);

            // now create a delegate using the delegate type and method we just constructed
            Delegate GetMethodDelegate = Delegate.CreateDelegate(DelegateType, proxy, GetValueMethod);

            // method name on IEnumerable/IOrderedEnumerable to call later
            string MethodName = null;

            // do we already have at least one sort on this collection?
            if (Source is IOrderedEnumerable<T>)
            {
                if (SortDirection == SortDirection.Ascending)
                    MethodName = "ThenBy";
                else
                    MethodName = "ThenByDescending";
            }
            else // first sort on this collection
            {
                if (SortDirection == SortDirection.Ascending)
                    MethodName = "OrderBy";
                else
                    MethodName = "OrderByDescending";
            }

            MethodInfo method = typeof(Enumerable).GetMethods()
                .Single(m => m.Name == MethodName && m.MakeGenericMethod(typeof(int), typeof(int)).GetParameters().Length == 2);

            return method.MakeGenericMethod(typeof(T), MemberType)
                .Invoke(Source, new object[] { Source, GetMethodDelegate }) as IOrderedEnumerable<T>;
        }
    }

    public class ValueProxy
    {
        private MemberInfo Member;

        public T GetValue<T, TKey>(TKey obj)
        {
            if (Member is FieldInfo)
                return (T)(Member as FieldInfo).GetValue(obj);
            else if (Member is PropertyInfo)
                return (T)(Member as PropertyInfo).GetValue(obj, null);

            return default(T);
        }

        public ValueProxy(MemberInfo Member)
        {
            this.Member = Member;
        }
    }

}

